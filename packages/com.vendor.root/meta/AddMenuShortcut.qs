function Component()
{
    // default constructor
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install README.txt!
    component.createOperations();

    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/bin/Printing Rates.exe", "@StartMenuDir@/Printing Rates.lnk",
            "workingDirectory=@TargetDir@", "description=Open Printing Rates");
    }
}
