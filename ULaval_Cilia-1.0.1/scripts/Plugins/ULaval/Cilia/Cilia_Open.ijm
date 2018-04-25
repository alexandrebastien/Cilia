// === OPEN BUTTON ===
macro "Open Results" {
     requires("1.35r");
     lineseparator = "\n";
     cellseparator = ",\t";
     
	 // define array for points
	 var xpoints = newArray;
	 var ypoints = newArray; 

     // copies the whole RT to an array of lines
     lines=split(File.openAsString(""), lineseparator);

     // recreates the columns headers
     labels=split(lines[0], cellseparator);
     if (labels[0]==" "){
        k=1; // it is an ImageJ Results table, skip first column
     }
     else {
        k=0; // it is not a Results table, load all columns
     }
     for (j=k; j<labels.length; j++) {
        setResult(labels[j],0,0);
        if (matches(labels[j],"x") || matches(labels[j],"X"))
        	iX = j;
        if (matches(labels[j],"y") || matches(labels[j],"Y"))
        	iY = j;
     }
     // dispatches the data into the new RT
     run("Clear Results");
     for (i=1; i<lines.length; i++) {
        items=split(lines[i], cellseparator);
     	setOption("ExpandableArrays", true);   
   		xpoints[i-1] = parseInt(items[iX]);
   		ypoints[i-1] = parseInt(items[iY]);
        for (j=k; j<items.length; j++)
           setResult(labels[j],i-1,items[j]);
     }
     updateResults();
     // show the points in the image
	 makeSelection("point", xpoints, ypoints); 
}