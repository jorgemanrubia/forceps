# Forceps

Have you ever needed to copy a given user from a production database into your local box in order to debug some obscure bug? 

Forceps lets you copy related models from one database into another. The source and target databases must support an active record connection. Typically, your source database is a remote production database and your target database is a local development one. The terms _local_ and _remote_ appears with this usage in mind thorough the API and code.

## Installing

In your `Gemfile`:

```ruby
gem 'forceps'
```

## Usage

### Configure a remote database connection

Add a node labeled `remote` to your `database.yml`

```ruby
remote:
  adapter: mysql2
  host: somehost.com
  port: 5432
  username: someuser
  password: somepassword
  database: somedatabase
  encoding: utf8
```

The low level connection mechanism doesn't matter thanks to Active Record. For example, this gem has been tested on [MySQL tunneled over SSH](http://chxo.com/be2/20040511_5667.html) and [on Heroku using the Postgres credentials](https://devcenter.heroku.com/articles/heroku-postgresql#pg-credentials).

### Copy models

To configure forceps you must invoke:

```ruby
Forceps.configure
```

This will take each Active Record model defined in the project and define a class that will mirror it in the remote database. These classes will live in the `Forceps::Remote` namespace.

For example, given:

```ruby
class Invoice < ActiveRecord::Base
end
```

You can use the generated class to download some invoice:

```ruby
Forceps::Remote::Invoice.find(1234).copy_to_local
```

By default, Forceps will:

1. Create a new local object copying all the attributes of the remote object
2. Explore all the associations of the remote object, and copy the related objects applying (1)

In most real-life situations you will want to tune this behavior:

#### Exclude associated models

Forceps lets you exclude associations from the automatic discovery process, in order to avoid downloading big chunks of unrelated data:

For example:

```Ruby
class Invoice < ActiveRecord::Base
  has_many :line_items
end

class LineItem < ActiveRecord::Base
  belongs_to :product
end

class Product < ActiveRecord::Base
  has_many :line_items
end
```

If you execute:

```ruby
Forceps.configure
Forceps::Remote::Invoice.find(1234).copy_to_local
```

It could end up downloading all the line items in the database:

```ruby
invoice 1
	line item 1
		product 1
			line item 2 # we are not interested in these line items
			line item 3
			line item 4
			line item 5
```
The option `exclude` lets you specify which associations you are not interested in:

```ruby
Forceps.configure exclude: {Product => [:line_items]}
```

#### Reuse models

Sometimes you don't want to clone an object. Instead, you want to use one that already exists in your database.

For example:

```ruby
class Product < ActiveRecord::Base
  has_and_belongs_to_many :tags
end
```

What about if the tags are reused across all the products in your database? For situations like this you can use the `reuse` option.

It can be used providing the name of a column that can be used to find the object:

```ruby
Forceps.configure reuse: {Tag => :name}
Forceps::Remote::Product.find(1234).copy_to_local # for each remote tag, it will try to find a tag with the same name
```

And, more generically, with a lambda that takes the local and remote objects and return the matched object (or nil if not found). The equivalent to the previous example would be:

```ruby
Forceps.configure reuse: {Tag => ->(local_tag, remote_tag) {Tag.find_by_name remote_tag.name}}
Forceps::Remote::Product.find(1234).copy_to_local 
```

When a `reuse` option is provided but the model can't be found locally, it will be cloned normally.

#### Callbacks

You can configure callbacks that will be invoked after each object is copied. You can use these callbacks to perform additional operations that are needed to perform the copy. For example: to copy S3 assets:

```ruby
Forceps.configure after_each: {
	Invoice => lambda do |local_upload, remote_upload|
		...
	end
}
```

## Compatibility

Rails 3 and 4

## Disclaimer

- If you are going to use this with a production database, it is recommended to use a read-only connection. Forceps will never modify the remote data but prevention is definitely better than cure when it comes to production data.
- Thanks to [bandzoogle](http://bandzoogle.com) for supporting the development of this project.

Pull requests are welcomed!

