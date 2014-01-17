class Car < Product
  def name=(new_name)
    super("CAR: #{new_name}")
  end
end
