// Basketly · place-order Edge Function
//
// The app sends WHAT to buy (product ids, quantities, options) and never
// the prices. This function loads the real prices from the database,
// re-checks every rule, and only then saves the order. A modified app
// cannot buy a smart watch for Rs 1.

import { createClient } from "npm:@supabase/supabase-js@2";

const FREE_DELIVERY_THRESHOLD = 2500;
const DELIVERY_FEE = 199;
const PROMOS: Record<string, (subtotal: number) => number> = {
  BASKET10: (subtotal) => Math.min(Math.round(subtotal * 0.1), 500),
};

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const reply = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const fail = (message: string, status = 400) => reply({ error: message }, status);

type Item = { product_id: string; quantity: number; size?: string | null; colour?: string | null };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return fail("Use POST.", 405);

  // The service-role client can write orders. It never leaves the server.
  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // 1. Who is ordering? The app sends the signed-in person's token.
  const token = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
  const { data: auth } = await admin.auth.getUser(token);
  const user = auth?.user;
  if (!user) return fail("Please sign in again.", 401);

  let body: any;
  try {
    body = await req.json();
  } catch {
    return fail("The order could not be read.");
  }

  // 2. Check the shape of everything that came in.
  const items: Item[] = Array.isArray(body.items) ? body.items : [];
  if (items.length === 0 || items.length > 50) return fail("Your basket is empty.");
  for (const item of items) {
    if (typeof item.product_id !== "string") return fail("An item is missing.");
    if (!Number.isInteger(item.quantity) || item.quantity < 1 || item.quantity > 20) {
      return fail("Each item can be ordered 1 to 20 times.");
    }
  }

  const paymentMethod = body.payment_method;
  if (paymentMethod !== "cod" && paymentMethod !== "demo_card") {
    return fail("Choose how you'd like to pay.");
  }

  const address = body.address ?? {};
  const phoneDigits = String(address.phone ?? "").replace(/\D/g, "");
  if (
    String(address.full_name ?? "").trim().length < 2 ||
    phoneDigits.length < 10 || phoneDigits.length > 13 ||
    String(address.line ?? "").trim().length < 5 ||
    String(address.city ?? "").trim().length < 2
  ) {
    return fail("Check your delivery address.");
  }

  const slotStart = new Date(body.slot_start);
  const now = Date.now();
  if (isNaN(slotStart.getTime()) || slotStart.getTime() < now ||
      slotStart.getTime() > now + 3 * 24 * 60 * 60 * 1000) {
    return fail("That delivery time is no longer available. Pick another.");
  }
  const slotLabel = String(body.slot_label ?? "").slice(0, 40);

  // 3. Load the REAL products and prices.
  const ids = [...new Set(items.map((i) => i.product_id))];
  const { data: products, error: productError } = await admin
    .from("products")
    .select("id, name, price, sizes, sold_out_sizes, colours")
    .in("id", ids);
  if (productError) return fail("Could not check prices. Try again.", 500);

  const byId = new Map(products!.map((p: any) => [p.id, p]));
  const lines = [];
  for (const item of items) {
    const product: any = byId.get(item.product_id);
    if (!product) return fail("An item in your basket is no longer sold.");

    if (product.sizes.length > 0) {
      if (!item.size || !product.sizes.includes(item.size)) {
        return fail(`Choose a size for ${product.name}.`);
      }
      if (product.sold_out_sizes.includes(item.size)) {
        return fail(`${product.name} in size ${item.size} just sold out.`);
      }
    }
    const colourNames = (product.colours ?? []).map((c: any) => c.name);
    if (item.colour && !colourNames.includes(item.colour)) {
      return fail(`That colour of ${product.name} isn't available.`);
    }

    lines.push({
      product_id: product.id,
      name: product.name,
      price: product.price,
      quantity: item.quantity,
      size: item.size ?? null,
      colour: item.colour ?? null,
      line_total: product.price * item.quantity,
    });
  }

  // 4. Same pricing rules as the app, worked out here.
  const subtotal = lines.reduce((sum, l) => sum + l.line_total, 0);
  const promoCode = typeof body.promo_code === "string" ? body.promo_code.trim().toUpperCase() : null;
  const promo = promoCode ? PROMOS[promoCode] : undefined;
  const discount = promo ? promo(subtotal) : 0;
  const deliveryFee = subtotal >= FREE_DELIVERY_THRESHOLD ? 0 : DELIVERY_FEE;
  const total = subtotal - discount + deliveryFee;

  // 5. Save the order, then its items.
  const { data: order, error: orderError } = await admin
    .from("orders")
    .insert({
      user_id: user.id,
      payment_method: paymentMethod,
      subtotal,
      discount,
      delivery_fee: deliveryFee,
      total,
      promo_code: promo ? promoCode : null,
      address: {
        full_name: String(address.full_name).trim(),
        phone: phoneDigits,
        line: String(address.line).trim(),
        city: String(address.city).trim(),
      },
      slot_start: slotStart.toISOString(),
      slot_label: slotLabel,
    })
    .select("id, number")
    .single();
  if (orderError) return fail("Could not save your order. Try again.", 500);

  const { error: itemsError } = await admin
    .from("order_items")
    .insert(lines.map((l) => ({ ...l, order_id: order.id })));
  if (itemsError) {
    await admin.from("orders").delete().eq("id", order.id); // no half-saved orders
    return fail("Could not save your order. Try again.", 500);
  }

  return reply({
    id: order.id,
    number: order.number,
    total,
    slot_label: slotLabel,
    payment_method: paymentMethod,
  });
});
