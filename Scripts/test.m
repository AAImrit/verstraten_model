%obtain contant values
currentPath = which(mfilename);
constantPath = fileparts(fileparts(currentPath))+ "\constant.txt";
constant = txt_to_dict(constantPath);

