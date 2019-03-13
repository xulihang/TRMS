B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.8
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

Sub extractToTxt(sl As String,tl As String,filepath As String,outputDir As String) As ResumableSub
	SetSystemProperty("sun.java2d.cmm", "sun.java2d.cmm.kcms.KcmsServiceProvider")
	Dim sh As Shell
	Dim args As List
	args.Initialize
	Dim extension As String
	Dim filename As String
	Dim dir As String
	filename=File.GetName(filepath)
	If File.Exists(File.DirTemp,filename&".xlf") Then
		File.Delete(File.DirTemp,filename&".xlf")
	End If
	dir=File.GetFileParent(filepath)
	extension=getExtension(filename)
	Log("extension"&extension)
	Dim fcConfMap As Map
	fcConfMap=getfcConfMap
	If fcConfMap.ContainsKey(extension) Then
		Dim settings As Map
		settings=fcConfMap.Get(extension)
		Dim configId As String
		configId=settings.Get("configId")
		args.AddAll(Array As String("-jar",tikalPath,"-x","-sl",sl,"-tl",tl,filepath,"-fc",configId,"-od",File.DirTemp))
	Else
		args.AddAll(Array As String("-jar",tikalPath,"-x","-sl",sl,"-tl",tl,filepath,"-od",File.DirTemp))
	End If
	sh.Initialize("sh","java",args)
	sh.Run(-1)
	wait for sh_ProcessCompleted (Success As Boolean, ExitCode As Int, StdOut As String, StdErr As String)
	If Success And ExitCode = 0 Then
		Log("Success")
		Log(StdOut)
		Dim text As String
		text=xliffFilter.getText(File.Combine(File.DirTemp,filename&".xlf"))
		If filename.EndsWith(".pdf") Then
			text=Utils.removeLines(text)
		End If
		File.WriteString(outputDir,filename&".txt",text)
		Success=True
	Else
		Log("Error: " & StdErr)
		Success=False
	End If
	Return Success
End Sub

Sub tikalPath As String
	Return File.Combine(File.Combine(File.Combine(File.DirApp,"okapi"),"lib"),"tikal.jar")
End Sub

Sub getExtension(filename As String) As String
	Try
		Return filename.SubString2(filename.LastIndexOf(".")+1,filename.Length)
	Catch
		Log(LastException)
		Return ""
	End Try
End Sub

Sub getfcConfMap As Map
	Dim result As Map
	result.Initialize
	Try
		Dim conf As List
		conf=File.ReadList(File.Combine(File.DirApp,"okapi"),"fc.conf")
		For Each line In conf
			Dim settings As Map
			settings.Initialize
			Dim extension,configId As String
			extension=Regex.Split("	",line)(0)
			configId=Regex.Split("	",line)(1)
			settings.Put("configId",configId)
            Try
				Dim outputEncoding As String
				outputEncoding=Regex.Split("	",line)(2)
				settings.Put("oe",outputEncoding)
			Catch
				Log(LastException)
			End Try
			result.Put(extension,settings)
		Next
	Catch
		Log(LastException)
	End Try
	Return result
End Sub