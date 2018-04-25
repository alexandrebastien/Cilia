// === BACK BUTTON ===
macro "Back [n4]" {
	// Get pt and zm
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	zm = parseFloat(call("ij.Prefs.get", "ma_config.zm",100));
	
	// Make pt -1
	pt = pt - 1;
	if (pt==0) {pt = 1;}

	// Get ctg (category), and position x y
	ctg = getResultString("category",pt-1);
	x = getResult("x",pt-1); y = getResult("y",pt-1);	

	// Update status, zoom, position and label
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
	run("Set... ", "zoom="+zm+" x="+x+" y="+y);
	run("Point Tool...", "type=Hybrid color=Magenta size=Large label");
	//makePoint(x, y);
	
	// Update pt and zm
	call("ij.Prefs.set", "ma_config.pt",pt);
	call("ij.Prefs.set", "ma_config.zm",zm);
}