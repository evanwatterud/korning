# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

employees = []
customers = []
products = []
CSV.foreach("sales.csv", :headers => true) do |row|
  employees << row["employee"] unless employees.include?(row["employee"])
  customers << row["customer_and_account_no"] unless customers.include?(row["customer_and_account_no"])
  products << row["product_name"] unless products.include?(row["product_name"])
end

db_connection { |conn|
  employees.each do |employee|
    name = "#{employee[0]} #{employee[1]}"
    email = employee.scan(/\(([^\)]+)\)/).last.first
    conn.exec("INSERT INTO employees(employee, email) VALUES ('#{name}', '#{email}')")
  end

  customers.each do |customer|
    name = customer[0]
    account_no = customer.scan(/\(([^\)]+)/).last.first
    conn.exec("INSERT INTO customers(customer, account_no) VALUES ('#{name}', '#{account_no}')")
  end

  products.each do |product|
    conn.exec("INSERT INTO products(name) VALUES ('#{product}')")
  end

  CSV.foreach("sales.csv", :headers => true) do |row|
    employee_id_num = conn.exec("SELECT id FROM employees WHERE employee = '#{row["employee"][0]} #{row["employee"][1]}'").to_a.first['id']
    customer_id_num = conn.exec("SELECT id FROM customers WHERE customer = '#{row["customer_and_account_no"][0]}'").to_a.first['id']
    product_id_num = conn.exec("SELECT id FROM products WHERE name = '#{row["product_name"]}'").to_a.first['id']
    sql = <<-eos
      INSERT INTO sales(employee_id, customer_id, product_id, sale_date, sale_amount, units_sold, invoice_no, invoice_frequency)
      VALUES (#{employee_id_num}, #{customer_id_num}, #{product_id_num}, '#{row["sale_date"]}', '#{row["sale_amount"]}', '#{row["units_sold"]}', '#{row["invoice_no"]}', '#{row["invoice_frequency"]}')
    eos
    conn.exec(sql)
  end
}
