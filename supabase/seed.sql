-- Optional sample data (run AFTER setup.sql). Gives you enough products to see pagination.
insert into public.categories (name)
select n from (values ('Coffee Beans'), ('Matcha'), ('Brewing Gear')) as v(n)
where not exists (select 1 from public.categories c where c.name = v.n);

insert into public.products (name, description, stock, price, category_id)
select p.name, p.description, p.stock, p.price, c.id
from (values
  ('Arabica Medium Roast 250g',  'Smooth and balanced, notes of caramel and cocoa.', 40, 350.00, 'Coffee Beans'),
  ('Barako Dark Roast 250g',     'Bold, earthy and strong. A local favorite.',        25, 320.00, 'Coffee Beans'),
  ('Single Origin Light Roast 250g', 'Bright and fruity with a clean finish.',         18, 420.00, 'Coffee Beans'),
  ('Espresso Blend 500g',        'Rich crema, built for milk drinks.',                30, 590.00, 'Coffee Beans'),
  ('Decaf Arabica 250g',         'All the flavor, none of the jitters.',               3, 380.00, 'Coffee Beans'),
  ('Ceremonial Matcha 30g',      'Vibrant, sweet and smooth. Best whisked plain.',    20, 690.00, 'Matcha'),
  ('Culinary Matcha 100g',       'Great for lattes and baking.',                      35, 450.00, 'Matcha'),
  ('Matcha Latte Mix 500g',      'Just add milk. Lightly sweetened.',                 28, 520.00, 'Matcha'),
  ('Bamboo Whisk (Chasen)',      'Hand-carved whisk for frothy matcha.',              15, 280.00, 'Matcha'),
  ('Ceramic Pour-over Dripper',  'Makes a clean, sweet cup. Fits size 02 filters.',   12, 750.00, 'Brewing Gear'),
  ('Gooseneck Kettle 1L',        'Precise pouring control.',                           8, 1890.00, 'Brewing Gear'),
  ('Hand Grinder',               'Adjustable burr grinder, 30g capacity.',             0, 1450.00, 'Brewing Gear')
) as p(name, description, stock, price, category)
join public.categories c on c.name = p.category
where not exists (select 1 from public.products x where x.name = p.name);

-- ---------------------------------------------------------------------
-- Make YOUR account an admin (sign up in the app first, then run this
-- with your own email). Every new account starts as a customer.
-- ---------------------------------------------------------------------
-- update public.profiles
-- set role_id = (select id from public.roles where role = 'admin')
-- where email = 'you@example.com';
