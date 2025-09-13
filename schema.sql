CREATE TABLE "categories" (
  "category_id" integer PRIMARY KEY,
  "category_name" varchar,
  "parent_category_id" integer
);

CREATE TABLE "products" (
  "product_id" integer PRIMARY KEY,
  "product_name" varchar,
  "price" decimal,
  "description" text,
  "availability" boolean,
  "category_id" integer NOT NULL
);

CREATE TABLE "regions" (
  "region_id" integer PRIMARY KEY,
  "region_name" varchar,
  "country" varchar
);

CREATE TABLE "customers" (
  "customer_id" integer PRIMARY KEY,
  "name" varchar,
  "email" varchar UNIQUE,
  "address" varchar,
  "city" varchar,
  "postal_code" varchar,
  "region_id" integer,
  "registration_date" date
);

CREATE TABLE "orders" (
  "order_id" integer PRIMARY KEY,
  "customer_id" integer NOT NULL,
  "order_date" timestamp,
  "status" varchar
);

CREATE TABLE "order_items" (
  "order_item_id" integer PRIMARY KEY,
  "order_id" integer NOT NULL,
  "product_id" integer NOT NULL,
  "quantity" decimal,
  "unit_price" decimal
);

CREATE TABLE "transactions" (
  "transaction_id" integer PRIMARY KEY,
  "order_id" integer NOT NULL,
  "txn_date" timestamp,
  "payment_method" varchar,
  "amount" decimal
);

COMMENT ON COLUMN "categories"."parent_category_id" IS 'NULL if top-level';

ALTER TABLE "products" ADD FOREIGN KEY ("category_id") REFERENCES "categories" ("category_id");

ALTER TABLE "categories" ADD FOREIGN KEY ("parent_category_id") REFERENCES "categories" ("category_id");

ALTER TABLE "customers" ADD FOREIGN KEY ("region_id") REFERENCES "regions" ("region_id");

ALTER TABLE "orders" ADD FOREIGN KEY ("customer_id") REFERENCES "customers" ("customer_id");

ALTER TABLE "order_items" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id");

ALTER TABLE "order_items" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("product_id");

ALTER TABLE "transactions" ADD FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id");
