str = "";
str = str + "macro \"Back [n4]\" {run(\"Cilia Back\");}\n";
str = str + "macro \"Forward [n6]\" {run(\"Cilia Forward\");}\n";
str = str + "macro \"Zoom In [n8]\" {run(\"Cilia Zoom In\");}\n";
str = str + "macro \"Basale [n1]\" {run(\"Cilia Basale\");}\n";
str = str + "macro \"Musculaire [n2]\" {run(\"Cilia Musculaire\");}\n";
str = str + "macro \"Delete [n3]\" {run(\"Cilia Delete\");}\n";
str = str + "macro \"Zoom Out [n5]\" {run(\"Cilia Zoom Out\");}\n";

path = getDirectory("temp") + "CiliaShortcuts.ijm" ;
File.saveString(str, path);
run("Install...", "install="+path);