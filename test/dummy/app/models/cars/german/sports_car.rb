class Cars::German::SportsCar < Car
  def name=(new_name)
    super("GERMAN SPORTS CAR: #{new_name}")
  end
end
