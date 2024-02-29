--if ac.getTrackId() ~= "ecu_dyno" then
--  return nil
--end

fuel = 0


function script.update(dt)
  data = ac.getCar()
  fuel = ac.load("fuel")
  
  physics.setCarFuel(0, fuel)

	
  --ac.log(distance)
  
end