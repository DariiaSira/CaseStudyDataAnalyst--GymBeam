CREATE TABLE "categories" (
  "category_id" integer PRIMARY KEY,
  "category_name" varchar NOT NULL,
  "parent_category_id" integer
);

CREATE TABLE "products" (
  "product_id" integer PRIMARY KEY,
  "product_name" varchar NOT NULL,
  "price" numeric(12,2) NOT NULL,
  "description" text,
  "availability" boolean NOT NULL,
  "category_id" integer NOT NULL
);

CREATE TABLE "regions" (
  "region_id" integer PRIMARY KEY,
  "region_name" varchar NOT NULL,
  "country" varchar NOT NULL
);

CREATE TABLE "customers" (
  "customer_id" integer PRIMARY KEY,
  "name" varchar NOT NULL,
  "email" varchar UNIQUE NOT NULL,
  "address" varchar,
  "city" varchar,
  "postal_code" varchar,
  "region_id" integer NOT NULL,
  "registration_date" date NOT NULL
);

CREATE TABLE "orders" (
  "order_id" integer PRIMARY KEY,
  "customer_id" integer NOT NULL,
  "order_date" timestamp NOT NULL,
  "status" varchar NOT NULL
);

CREATE TABLE "order_items" (
  "order_item_id" integer PRIMARY KEY,
  "order_id" integer NOT NULL,
  "product_id" integer NOT NULL,
  "quantity" numeric(12,3) NOT NULL,
  "unit_price" numeric(12,2) NOT NULL
);

CREATE TABLE "transactions" (
  "transaction_id" integer PRIMARY KEY,
  "order_id" integer NOT NULL,
  "txn_date" timestamp NOT NULL,
  "payment_method" varchar NOT NULL,
  "amount" numeric(12,2) NOT NULL
);

COMMENT ON COLUMN "categories"."parent_category_id" IS 'NULL if top-level';

COMMENT ON COLUMN "orders"."status" IS 'ENUM napr. NEW, PAID, SHIPPED, CANCELLED';

COMMENT ON COLUMN "transactions"."payment_method" IS 'ENUM napr. CARD, PAYPAL, BANK_TRANSFER';

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("category_id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "categories" ADD FOREIGN KEY ("parent_category_id") REFERENCES "categories" ("category_id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "customers" ADD FOREIGN KEY ("region_id") REFERENCES "regions" ("region_id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id") ON DELETE CASCADE ON UPDATE CASCADE;
