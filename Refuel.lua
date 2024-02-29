data = ac.getCar()
fuel = data.fuel


function script.update(dt)
  data = ac.getCar()
  fuel = ac.load("fuel")
  
  physics.setCarFuel(0, fuel)

	
  
end
