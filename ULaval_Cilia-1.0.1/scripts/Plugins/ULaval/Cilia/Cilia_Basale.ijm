// === B BUTTON ===
macro "Basale [n1]" {
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	ctg = "B";
	setResult("category", pt-1, ctg)
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
}