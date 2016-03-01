Configuration Website 
{ 
	  param ($MachineName)

	  Node $MachineName
	  { 
		#Install the IIS Role 
		WindowsFeature IIS 
		{ 
		  Ensure = "Present"
		  Name = "Web-Server"
		} 

		#Install ASP.NET 4.5 
		WindowsFeature ASP 
		{ 
		  Ensure = "Present"
		  Name = "Web-Asp-Net45"
		} 
	  } 
} 