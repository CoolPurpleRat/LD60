extends Node
class_name commonFunctions

##Display in X*10^Y format
var scienceNumberNotation:bool=false
##tranform big float number to readable text, e.g. 5000->5k
func numberFormat(number:float, Fractional:bool=false)->String:
	var textRaw:PackedStringArray
	#search suffix id
	var searchKey:float=0
	var returnNumber:String="bug at numberFormat() at commonFunctions"
	##All suffixes
	const numberNames:Dictionary[String, float]={
		"k":pow(10,3),
		"M":pow(10,6),
		"B":pow(10,9),
		"T":pow(10,12),
		"Qa":pow(10,15),
		"Qi":pow(10,18),
		"Sex":pow(10,21),
		"Sp":pow(10,24),
		"O":pow(10,27),
		"N":pow(10,30),
		"D":pow(10,33),
		"Du":pow(10,39),
		"Tr":pow(10,42),
		"Qua":pow(10,45),
		"Qui":pow(10,48),
		"SexDec":pow(10,51),
		"Oc":pow(10,57),
		"Nov":pow(10,60),
		"V":pow(10,63),
		"Unv":pow(10,66),
		"Duo":pow(10,69),
		"Tre":pow(10,72),
		"Quat":pow(10,75),
		"Quin":pow(10,78),
		"SexV":pow(10,81),
		"Sep":pow(10,84),
		"Octo":pow(10,87),
		"No":pow(10,90),
		"Tri":pow(10,93),
		"Untri":pow(10,96),
		"Duot":pow(10,99),
		"Googel":pow(10,100),
	}
	
	#return without suffix if small
	if number<numberNames.values().min():
		textRaw=str(number).split(".")
		returnNumber=textRaw[0]
		if Fractional:
			returnNumber+="."+textRaw[1].substr(0,3)
	
	elif number<(numberNames.values().max()*1000) and not scienceNumberNotation:
		if number>numberNames.values().max():
			number/=numberNames.values().max()
			textRaw=str(number).split(".")
			returnNumber=textRaw[0]+"."+textRaw[1].substr(0,2)+numberNames.find_key(numberNames.values().max())
		else:
			var previousNumberName:float=numberNames.values().min()
			for numberName in numberNames:
				if number>previousNumberName and number<numberNames[numberName]:
					searchKey=previousNumberName
					break
				previousNumberName=numberNames[numberName]
			number/=searchKey
			textRaw=str(number).split(".")
			returnNumber=textRaw[0]+"."+textRaw[1].substr(0,2)
			returnNumber+=numberNames.find_key(searchKey)
	#if bigger than max suffix or forced science notation return science notation
	else:
		textRaw=str(number).split(".")
		returnNumber=textRaw[0].substr(0,1)+"."+textRaw[0].substr(1,2)
		returnNumber+="*10^"+str(textRaw[0].length()-1)	
	return returnNumber

##sum of x and y of Vector2
func vec2sum(vector:Vector2)->float:
	return vector.x+vector.y

##mult of x and y of Vector2
func vec2mult(vector:Vector2)->float: 
	return vector.x*vector.y
	
##sum of x,y,z of Vector3
func vec3sum(vector:Vector3)->float:
	return vector.x+vector.y+vector.z
	
##mult of x,y,z of Vector3
func vec3mult(vector:Vector3)->float:
	return vector.x*vector.y*vector.z

##give random direction vector from two angles. Angles in degrees
func randVec2dir(angleMin:float=0, angleMax:float=360)->Vector2:
	var degree:float=randf_range(angleMin, angleMax)
	var degreeRad:float=deg_to_rad(degree)
	var returnVector:Vector2=Vector2(cos(degreeRad),sin(degreeRad)).normalized()
	return returnVector

##vector 2 from angle. Angle in degrees
func Vec2FromAngle(angle:float)->Vector2:
	var returnVector:Vector2=Vector2.RIGHT.rotated(deg_to_rad(angle))
	return returnVector
