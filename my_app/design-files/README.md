# teleBabies — Design Handoff for Claude Code

A complete reference package for implementing the **teleBabies** mobile app — a Yemeni e-commerce app for kids' and babies' clothing. This bundle contains **high-fidelity HTML prototypes** that demonstrate the intended look, behavior, and flows of the app.

---

## ⚠️ Important: How to Use This Package

The HTML files in `design-files/` are **design references**, not production code. They are React-via-Babel prototypes built to be viewed in a browser as living mockups. **Do not ship them as-is.**

Your job (as the developer using Claude Code) is to:

1. **Open `design-files/teleBabies App.html`** in a browser and explore every screen and interaction.
2. **Pick the right framework for production.** This is a Yemeni mobile e-commerce app intended for Android. The best choice is **Flutter** (the original spec called for Flutter Android) or **React Native**. The backend should be **Node.js + Express + PostgreSQL** (or MongoDB) with JWT auth.
3. **Recreate the designs pixel-for-pixel** in that framework, translating the React/CSS patterns into native equivalents (Flutter widgets, RN components, etc.). Use the prototype's exact colors, spacing, typography, and copy.

---

## Project Overview

**Product:** teleBabies (تيليبيبيز) — kids' and babies' clothing e-commerce app
**Market:** Yemen (RTL Arabic primary, English secondary)
**Currency:** YER (Yemeni Rial)
**Platform:** Android mobile app (single APK serves both customers and admins)
**Architecture:** One app, role-based routing — see "Auth & Role Routing" below

---

## Fidelity

**High-fidelity.** All screens have final colors, typography, spacing, copy, and interactions. Every value in `app/brand.css` is the production value — use it directly. Product photos are placeholders sourced from Unsplash; the real app will use the merchant's own product photography (handled via the admin panel's product upload).

---

## Auth & Role Routing (CRITICAL)

The app uses **one APK for both customers and admins** with backend-driven role routing. There is **no separate admin app** and **no admin login link** in the UI. The admin uses the same login screen as everyone else.

### Flow
1. User opens the app → Login screen
2. Enters phone number (+967) → backend sends OTP via SMS
3. Enters 4-digit OTP → backend verifies and looks up the phone in the `admins` table
   - **In `admins` table** → backend returns `{ role: 'admin', ... }` → app skips name capture, routes to admin panel
   - **Not in `admins`** → backend returns `{ role: 'customer', ... }` → app captures name (first-time only), routes to customer home
4. App shows a "Verifying access…" splash for ~700ms during the role check
5. The role is stored in JWT; every admin endpoint independently re-verifies `user.role === 'admin'` server-side

### Why this matters
- **Customers never see anything that hints at admin features** — same login, same UI surface
- **Admins are added/removed by editing the DB**, not by an in-app flow
- **Security comes from the backend**, not the client. Even if a malicious user spoofs the role on the client, the backend rejects unauthorized requests.

In the prototype, the role is faked client-side: phone numbers starting with `70` are treated as admin. **Do not ship this.** The real check is server-side after OTP verification.

### Endpoints (suggested)
```
POST  /auth/request-otp   { phone }                  → { ok: true }
POST  /auth/verify-otp    { phone, otp }             → { token, user: { id, name?, phone, role } }
POST  /auth/set-name      { name }  (auth required)  → { ok: true } — for first-time customers
```

---

## Screens & Flows

The prototype has two main flow trees branching from a shared login.

### Customer flow
1. **Login** — phone → OTP → (name, first time only)
2. **Home** — greeting with user's name, featured products, trending grid, category chips
3. **Browse / Search** — full product grid with category filters, search bar, sort
4. **Product detail** — large hero image, name, price, size selector, description, "Add to cart"
5. **Cart** — line items with qty controls, subtotal, "Checkout" CTA
6. **Checkout (3-step)** — Address → Payment (incl. receipt upload for bank transfer) → Confirmation
7. **Order placed** — success state with order number and "Track order" CTA
8. **Orders list** — past orders with status pills (pending / shipped / delivered)
9. **Order detail** — line items, status timeline, total
10. **Account** — avatar with initials, name, phone, settings menu

### Admin flow
1. **Orders dashboard** — list of incoming orders with filter pills (pending / paid / shipped / delivered)
2. **Order detail** — customer info, items, payment receipt review (approve/reject), status update
3. **Products management** — list + add/edit product (name, price, photos, sizes, stock)
4. **Tabs:** Orders | Products | Settings

### Routing primitives
- The prototype uses a flat `route` state (`{ name: 'tabs' | 'product' | 'checkout' | ... }`) plus a `tab` for the bottom-tab section. In production, use the framework's native router (Flutter's `Navigator` / RN's `react-navigation`).
- The bottom tab bar has 5 tabs for customers (Home, Search, Cart, Orders, Account) and 3 for admins (Orders, Products, Settings).

---

## Design Tokens (use these exact values)

All defined in `design-files/app/brand.css` — copy them into your design system.

### Colors
| Token | Hex | Use |
|---|---|---|
| `--tb-yellow` | `#FFD23F` | Primary sunshine accent |
| `--tb-yellow-deep` | `#F4B400` | Deeper yellow for contrast |
| `--tb-pink` | `#FF4D8D` | Hot pink — login bg, accents |
| `--tb-pink-soft` | `#FFC2D8` | Soft pink — backgrounds |
| `--tb-mint` | `#2BD9A6` | Mint green — success, accent variant |
| `--tb-mint-soft` | `#BFF5E3` | Soft mint |
| `--tb-blue` | `#3B6BFF` | Electric blue |
| `--tb-blue-soft` | `#C8D6FF` | Soft blue |
| `--tb-purple` | `#8B5CF6` | Purple accent |
| `--tb-coral` | `#FF6B4A` | Coral accent |
| `--tb-cream` | `#FFF7E8` | Warm cream — backgrounds, button text on dark |
| `--tb-ink` | `#1A1530` | Deep eggplant — primary text & buttons (NOT pure black) |
| `--tb-ink-2` | `#4A4566` | Secondary text |
| `--tb-ink-3` | `#8A85A8` | Tertiary text / placeholders |
| `--tb-line` | `#E8E3D5` | Borders, dividers |
| `--tb-bg` | `#FAF6EC` | Page background |
| `--tb-card` | `#FFFFFF` | Card surfaces |

### Dark mode (use these when `data-theme="dark"`)
| Token | Hex |
|---|---|
| `--tb-cream` | `#1F1A36` |
| `--tb-bg` | `#14102A` |
| `--tb-card` | `#251F42` |
| `--tb-ink` | `#FFF7E8` |
| `--tb-ink-2` | `#C9C2E0` |
| `--tb-ink-3` | `#8C84B5` |
| `--tb-line` | `#3A2F58` |

### Typography
- **Display (Latin):** Funnel Display, weights 400–800
- **Body (Latin):** Plus Jakarta Sans, weights 400–800
- **Arabic (all):** IBM Plex Sans Arabic (primary), Cairo (fallback), weights 400–900
- **Display style:** weight 700, letter-spacing -0.02em (Latin) / 0 (Arabic), line-height 1.05
- **Sizes:** display 36/24/20px, body 15/13px, micro 12/11px

### Spacing & radii
- Border radii: `10px` (sm), `18px` (default), `28px` (lg), `36px` (xl)
- Buttons: pill (border-radius: 999px), padding `14px 22px`, font-size 15px, weight 700
- Card shadow (default): `0 8px 28px rgba(26, 21, 48, 0.10)`
- Inputs: border-radius 14px, padding `14px 16px`, border `1.5px solid var(--tb-line)`, focus border `var(--tb-accent)`

### Animations
- `tb-pop`: 0.35s scale-in for added items
- `tb-spin`: 1.5s linear infinite for loaders
- Button press: `transform: scale(0.97)` on `:active`, transition 0.12s

---

## RTL Support

The app is **Arabic-first**. Every screen must be tested in RTL.

- Set `dir="rtl"` on the document root when language is `ar`
- All flex layouts must flip naturally — use `flex-direction: row` and let RTL invert it (don't hardcode `row-reverse`)
- Use logical properties: `padding-inline-start`, `margin-inline-end`, etc. — never `padding-left` / `padding-right`
- Icons that have direction (arrows, back chevrons) must flip in RTL — the prototype uses separate `ArrowL` / `ArrowR` icons swapped by language; in Flutter use `Directionality` + `Transform.flip`
- The phone input is always `direction: ltr` regardless of app language — phone numbers read left-to-right
- The country code prefix (`🇾🇪 +967`) sits on the visual left, the input on the visual right (in RTL)

---

## Specific Screen Notes

### Login screen
- Background: hot pink (`--tb-pink`) top half, decorative yellow/mint shapes
- Wordmark "تيليبيبيز" / "teleBabies" white, 28px, top of pink area
- Bottom sheet: cream (`--tb-bg`), border-top-radius 36px, padding 28px 22px 22px
- 3 steps: phone → OTP → name (name only on first-time customer; admins skip)
- Phone field: 4-digit groups, country code `🇾🇪 +967` block on left (LTR), input on right (fills remaining width)
- OTP: 4 separate boxes, 56×64px, border-radius 16px, font-size 24px weight 800, autofocus next on input
- Name step: single text input with `autoFocus`, "Start shopping" button disabled until name has at least 1 non-whitespace char

### Home screen
- Top bar: greeting "مرحباً، 👋" + user's name (display font, 20px, weight 800), bell icon with notification dot
- Featured carousel: horizontal scroll of 4 cards with hero photos
- Categories row: horizontal scroll of pill chips with colored circle icons
- Trending grid: 2-column grid of product cards
- Product card: square photo with `aspect-ratio: 1`, name (2-line clamp), price, optional tag badge ("جديد" / "NEW" etc.), heart button top-right that toggles filled/unfilled state on tap
- Hover state on web (will become press state on mobile): image scale 1.06, card lifts with shadow

### Product detail
- Full-bleed photo at top (aspect 1:1)
- Title + tag badge
- Price (large, weight 800) with optional strikethrough old price beside it
- Size selector: row of pill chips, selected = filled `--tb-ink`
- Description: body text, 2 paragraphs max
- Sticky bottom bar: qty stepper (- 1 +) + "Add to cart" CTA filled with `--tb-accent`
- "Add to cart" plays `tb-pop` animation, navigates to Cart tab

### Cart
- Line item: 80×80 thumbnail, name, size, price, qty stepper, remove button
- Subtotal row, shipping row, total row (large)
- Sticky bottom: "Checkout" filled CTA showing total

### Checkout
- 3-step progress indicator at top (1 dots filled per step)
- Step 1 — Address: name, phone (prefilled from auth), city dropdown (Yemen cities), street address textarea
- Step 2 — Payment: method radio (cash on delivery / bank transfer), if bank → upload receipt photo (drag-drop area + camera icon)
- Step 3 — Receipt confirmation: order summary, place order CTA

### Admin orders dashboard
- Header: dark `--tb-ink` bg, yellow icon block, "لوحة الإدارة / Admin panel" eyebrow + "teleBabies" title
- Status filter pills: pending / paid / shipped / delivered with counts
- Order rows: order #, customer name, total, status pill, time ago, chevron
- Tap row → order detail

### Admin order detail
- Customer block with phone (tap to call)
- Items list (compact)
- Payment receipt: image preview with approve/reject buttons (only if bank transfer)
- Status changer: dropdown or stepper to advance order status
- Backend should send push notification to customer on status change

---

## Tweaks system (prototype-only)

The prototype includes a **Tweaks panel** for design review (toggle dark mode, switch accent color, swap home/product variants, change card style, switch language). **This is review-only — do not ship the panel.** But the underlying capabilities are useful:

- **Light/dark mode toggle** — wire to system preference + manual override
- **Language toggle (ar / en)** — wire to in-app language switcher in Settings
- The accent color and card style switches are exploratory — pick the final values (pink accent, shadow card style) for production unless the client decides otherwise

---

## Backend Spec (suggested)

```
POST   /auth/request-otp
POST   /auth/verify-otp
POST   /auth/set-name
GET    /products?cat=&search=&sort=
GET    /products/:id
GET    /cart                          (auth)
POST   /cart                          (auth)
DELETE /cart/:itemId                  (auth)
POST   /orders                        (auth) — body includes payment_method, address, receipt_image_url?
GET    /orders                        (auth) — customer's own orders
GET    /orders/:id                    (auth)

# Admin (require role: 'admin')
GET    /admin/orders?status=
PATCH  /admin/orders/:id              { status }
PATCH  /admin/orders/:id/receipt      { approved: true | false }
GET    /admin/products
POST   /admin/products
PATCH  /admin/products/:id
DELETE /admin/products/:id
POST   /admin/products/:id/photos     (multipart upload)
```

### Database tables (sketch)
- `users` (id, name, phone, role enum('customer','admin'), created_at)
- `admins` is just `users WHERE role = 'admin'` — no separate table needed; alternatively a `role_overrides` table
- `products` (id, name_ar, name_en, desc_ar, desc_en, price, currency, category, age, sizes JSON, stock, photos JSON, tag_ar, tag_en, created_at)
- `orders` (id, user_id, status, total, address JSON, payment_method, receipt_url, created_at)
- `order_items` (id, order_id, product_id, qty, size, price_snapshot)

---

## File Map (`design-files/`)

```
teleBabies App.html       Entry point — open this in a browser to see the prototype
android-frame.jsx         Phone bezel + status bar + nav bar primitives
tweaks-panel.jsx          Design-review tweaks panel (do not ship)
app/
  brand.css               Brand tokens — colors, type, components — COPY VALUES FROM HERE
  data.jsx                Sample products, categories, cities — replace with API calls
  icons.jsx               Custom-drawn SVG icon set used throughout
  shared.jsx              Shared UI atoms (status bar, tab bar, wordmark, currency formatter)
  main.jsx                App root — login routing, role splash, top-level state
  screens-home.jsx        Home + product card components
  screens-shop.jsx        Browse, product detail
  screens-flow.jsx        Cart, checkout, order placed, orders list, order detail, account
  screens-admin.jsx       Login screen + entire admin panel
```

---

## Implementation Checklist

- [ ] Set up Flutter (or RN) project with locale support (ar primary, en secondary, RTL-aware)
- [ ] Implement design tokens from `brand.css` as a `ThemeData` (Flutter) or theme object (RN)
- [ ] Load fonts: Funnel Display, Plus Jakarta Sans, IBM Plex Sans Arabic, Cairo
- [ ] Build the bottom tab navigator (5 tabs for customers, 3 for admins — read role from JWT)
- [ ] Implement login flow: phone → OTP → role-based routing → name capture (customer only)
- [ ] Build product list, product detail, cart, checkout
- [ ] Build orders list, order detail, account
- [ ] Build admin orders, admin order detail with receipt review, admin products CRUD
- [ ] Implement push notifications for order status changes
- [ ] Implement camera/gallery picker for receipt upload
- [ ] Test every screen in both Arabic (RTL) and English (LTR)
- [ ] Test light and dark mode
- [ ] Backend: OTP service (Twilio or local SMS gateway), JWT auth, role-gated endpoints, image upload to S3 or equivalent

---

## Questions for Product Owner Before Coding

1. SMS provider for OTP — Twilio, MessageBird, or local Yemeni SMS gateway?
2. Image hosting — S3, Cloudinary, or self-hosted?
3. Bank transfer flow — what bank accounts are receipts checked against? Manual approval only, or any automation?
4. Currency display — show YER as integer (no decimals) confirmed?
5. Localization — ship with `ar` only at launch, or both `ar`+`en`?
6. Push notifications — Firebase Cloud Messaging, or alternative?
7. Admin user management — how are new admins added? DB only, or super-admin in-app flow?

---

Built with care. Open `design-files/teleBabies App.html` in a browser as your primary reference.
