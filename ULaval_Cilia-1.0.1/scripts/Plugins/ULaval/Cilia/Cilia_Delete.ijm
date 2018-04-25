// === X BUTTON ===
macro "Delete [n3]" {
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	ctg = "X";
	setResult("category", pt-1, ctg)
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
}