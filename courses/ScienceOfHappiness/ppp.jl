#Preprintprocessor

files=["index.txt","week1.txt"]

file=files[1]
title="Science of Happiness"
text=readall(file)
while contains(text,"\n\n")
	text=replace(text,"\n\n","<br>\n")
end

linkloc=search(text,"http")
while linkloc!=0:-1

end

doc="""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>$title</title>
</head>
<body>


</body>
</html>"""
