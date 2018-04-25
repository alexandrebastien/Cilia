<startupAction>
call("ij.Prefs.set", "ma_config.pt",1);
call("ij.Prefs.set", "ma_config.zm",100);
run("Cilia Install Shortcuts");
</startupAction>

<line>
// === OPEN BUTTON ===
<button> 1 line 1
label=Open
icon=noicon
arg=<macro>
	run("Cilia Open");
</macro>

// === BACK BUTTON ===
<button> 2 line 1
label=Prev [4]
icon=noicon
arg=<macro>
	run("Cilia Back");
</macro>

// === FORWARD BUTTON ===
<button> 3 line 1
label=Next [6]
icon=noicon
arg=<macro>
	run("Cilia Forward");
</macro>

// === ZOOM IN BUTTON ===
<button> 4 line 1
label=Zoom In [8]
icon=noicon
arg=<macro>
	run("Cilia Zoom In");
</macro>

</line>
<line>

// === B BUTTON ===
<button> 1 line 2
label=Basale [1]
icon=noicon
arg=<macro>
	run("Cilia Basale");
</macro>

// === M BUTTON ===
<button> 2 line 2
label=Musculaire [2]
icon=noicon
arg=<macro>
	run("Cilia Musculaire");
</macro>

// === X BUTTON ===
<button> 3 line 2
label=X [3]
icon=noicon
arg=<macro>
	run("Cilia Delete");
</macro>

// === ZOOM OUT BUTTON ===
<button> 4 line 2
label=Zoom Out [5]
icon=noicon
arg=<macro>
	run("Cilia Zoom Out");
</macro>

</line>
// end of file
