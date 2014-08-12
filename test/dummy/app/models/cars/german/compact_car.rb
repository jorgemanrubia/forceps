class Cars::German::CompactCar < Car
  def name=(new_name)
    super("GERMAN COMPACT CAR: #{new_name}")
  end
end
