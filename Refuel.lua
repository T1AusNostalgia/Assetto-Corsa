
fuel = 0


function script.update(dt)
  data = ac.getCar()
  fuel = ac.load("fuel")
  
  physics.setCarFuel(0, fuel)

	
  
end
