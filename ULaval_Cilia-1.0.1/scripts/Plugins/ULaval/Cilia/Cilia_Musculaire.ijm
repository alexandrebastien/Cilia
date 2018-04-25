// === M BUTTON ===
macro "Musculaire [n2]" {
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	ctg = "M";
	setResult("category", pt-1, ctg)
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
}