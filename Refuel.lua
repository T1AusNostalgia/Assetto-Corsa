data = ac.getCar()
fuel = data.fuel
distance = 0
acceptable_distance = 10 --meter

gas1 = ""
gas2 = ""
gas3 = ""

ac.findMeshes('Sphere003'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))  
ac.findMeshes('Sphere002'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))
ac.findMeshes('Sphere001'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))

distance1 = 0
distance2 = 0
distance3 = 0
distance4 = 0

station_pos1 = vec3(5850.55,23.6,-4631.9)
station_pos2 = vec3(-222.9,13.1,1378.4)
station_pos3 = vec3(1108.5,26,-4648)
station_pos4 = vec3(4292,37.45,-8878.5)

function script.update(dt)
  data = ac.getCar()
  
  car_pos = data.position
  distance1 = math.distance(station_pos1, car_pos)
  distance2 = math.distance(station_pos2, car_pos)
  distance3 = math.distance(station_pos3, car_pos)
  distance4 = math.distance(station_pos4, car_pos)

  
  if distance1 < acceptable_distance or distance2 < acceptable_distance or distance3 < acceptable_distance or distance4 < acceptable_distance then
    distance = 1
  else
    distance = 0
  end	  
  
  fuel = ac.load("fuel")  
  physics.setCarFuel(0, fuel)

  gas1 = ac.isMeshPressed('Box1446', vec2(0, 0), vec2(1, 1), nil, 0.05, true)
  gas2 = ac.isMeshPressed('Box1442', vec2(0, 0), vec2(1, 1), nil, 0.05, true)
  gas3 = ac.isMeshPressed('Box1440', vec2(0, 0), vec2(1, 1), nil, 0.05, true)
  --ac.log(gas1)
  if gas1 == true and distance == 1 then
    ac.findMeshes('Sphere003'):setMaterialProperty('ksEmissive', rgb(0, 1000, 0))  
    ac.findMeshes('Sphere002'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))
    ac.findMeshes('Sphere001'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))
	ac.store("gas1_refuel", 1)
	ac.store("gas2_refuel", 0)	
	ac.store("gas3_refuel", 0)	
  elseif gas2 == true and distance == 1 then
    ac.findMeshes('Sphere003'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))  
    ac.findMeshes('Sphere002'):setMaterialProperty('ksEmissive', rgb(1000, 0, 0))
    ac.findMeshes('Sphere001'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))
	ac.store("gas1_refuel", 0)
	ac.store("gas2_refuel", 1)	
	ac.store("gas3_refuel", 0)	
  elseif gas3 == true and distance == 1 then
    ac.findMeshes('Sphere003'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))  
    ac.findMeshes('Sphere002'):setMaterialProperty('ksEmissive', rgb(0, 0, 0))
    ac.findMeshes('Sphere001'):setMaterialProperty('ksEmissive', rgb(0, 0, 3000))
	ac.store("gas1_refuel", 0)
	ac.store("gas2_refuel", 0)	
	ac.store("gas3_refuel", 1)
  else	
	ac.store("gas1_refuel", 0)
	ac.store("gas2_refuel", 0)	
	ac.store("gas3_refuel", 0)
  
  end		
  
end
