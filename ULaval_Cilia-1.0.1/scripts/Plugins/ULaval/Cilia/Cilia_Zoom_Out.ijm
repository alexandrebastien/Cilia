// === ZOOM OUT BUTTON ===
macro "Zoom Out [n5]" {
	// Get pt and zm
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	zm = parseFloat(call("ij.Prefs.get", "ma_config.zm",100));
	
	// Make zm x 1.5
	zm = zm*0.75;

	// Get ctg (category), and position x y
	ctg = getResultString("category",pt-1);
	x = getResult("x",pt-1); y = getResult("y",pt-1);	

	// Update status, zoom, position and label
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
	run("Set... ", "zoom="+zm+" x="+x+" y="+y);
	run("Point Tool...", "type=Hybrid color=Magenta size=Large label");
	//makePoint(x, y);

	//Make sure zoom is not too much
	zm = getZoom*100;
	
	// Update pt and zm
	call("ij.Prefs.set", "ma_config.pt",pt);
	call("ij.Prefs.set", "ma_config.zm",zm);
}