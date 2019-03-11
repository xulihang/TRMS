B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.7
@EndOfDesignText@
'Class module
Sub Class_Globals
	Private timer1 As Timer
	Private queue As Map
	Type item (FilePath As String,id As String)
	Private isOngoing As Boolean=False
End Sub

Public Sub Initialize
	queue.Initialize
	timer1.Initialize("timer1", 10 * DateTime.TicksPerMinute ) 'check for new libraries every 10 minutes * DateTime.TicksPerMinute
	timer1.Enabled = True
	Timer1_Tick
	StartMessageLoop	
End Sub

Private Sub Timer1_Tick
	
	Try
		If isOngoing=False Then
			If queue.Size=0 Then
				convertAndIndex(Main.originalFilesPath)
			Else
				Log("queue"&queue)
				handleQueue
			End If
		End If
	Catch
		Log(LastException)
	End Try

End Sub

private Sub convertAndIndex(path As String)
	For Each filename As String In File.ListFiles(path)
		If File.IsDirectory(path,filename) Then 'category
			Dim categoryPath As String=File.Combine(path,filename)
			For Each projectName As String In File.ListFiles(categoryPath)
				If File.IsDirectory(categoryPath,projectName) Then 'projectname
					Dim projectPath As String=File.Combine(categoryPath,projectName)
					addProject(projectPath)
				End If
			Next
		End If
	Next
	handleQueue
End Sub

Sub handleQueue
	isOngoing=True
	Dim items As List
	items.Initialize
	For Each item As item In queue.Keys
		items.Add(item)
	Next
	Log("queue: "&queue)
	For Each item As item In items
		wait for (IndexOne(item.FilePath,item.id)) complete (result As String)
		Log("result: "&result)
		If result="success" Then
			queue.Remove(item)
		else if result = "not supported" Then
			queue.Remove(item)
		End If
	Next
	isOngoing=False
End Sub

Private Sub addProject(projectPath As String)
	If File.Exists(projectPath,"source") Then
		For Each filename As String In File.ListFiles(File.Combine(projectPath,"source"))
			If File.Exists(File.Combine(projectPath,"target"),filename) Then
				addBitext(projectPath,filename)
			End If
		Next
	End If
End Sub

Private Sub addBitext (projectPath As String,filename As String) 
	Dim sourceFilePath As String=File.Combine(File.Combine(projectPath,"source"),filename)
	Dim targetFilePath As String=File.Combine(File.Combine(projectPath,"target"),filename)
	Dim categoryPath As String=File.GetFileParent(projectPath)
	
	Dim id As String
	id=File.GetName(categoryPath)&"_"&File.GetName(projectPath)
	Dim item1 As item
	item1.FilePath=sourceFilePath
	item1.id=id&"_source"
	Dim item2 As item
	item2.FilePath=targetFilePath
	item2.id=id&"_target"
	queue.Put(item1,"")
	queue.Put(item2,"")
End Sub

Private Sub IndexOne(FilePath As String,id As String) As ResumableSub
	Dim versions As Map
	If Main.esclient.Exists("meta", "dates", id) Then
		versions = Main.esclient.Get("meta", "dates", id)
		Log($"Current indexed libraries (${id})"$)
		For Each title As String In versions.Keys
			Log($"${title}: $DateTime{versions.Get(title)}"$)
		Next
	Else
		versions.Initialize
	End If
	
	Dim title As String=FilePath
	Try
		title = FilePath.SubString2(0, FilePath.LastIndexOf(".")) 'remove extension
	Catch
		Log(LastException)
	End Try
	
	Dim logMap As Map
	logMap.Initialize
	Dim failedTimes As Int
	Dim logPath As String=File.Combine(File.DirApp,"log.map")
	If File.Exists(logPath,"") Then
		logMap=File.ReadMap(logPath,"")
		failedTimes=logMap.GetDefault(title,0)
	End If
	
	Dim result As String
	If failedTimes<3 Then
		Dim currentDate As Long = versions.GetDefault(title, 0)
		Dim NewDate As Long = File.LastModified(FilePath, "")
		If currentDate < NewDate Then
			Dim outputFilePath As String=FilePath.Replace(Main.originalFilesPath,Main.documentsPath)
			Log("converting "&FilePath&" to "&outputFilePath&".txt")
			FileUtils.createNonExistingDir(outputFilePath)
			Dim text As String
			If FilePath.EndsWith(".txt") Then
				File.Copy(FilePath,"",outputFilePath,"")
				text=txtFilter.read(outputFilePath)
				IndexTxt(title, outputFilePath,text)
				versions.Put(title, NewDate)
				result="success"
			Else
				wait for (tikal.extractToTxt("en","zh",FilePath,File.GetFileParent(outputFilePath))) complete (success As Boolean)
				If success=True Then
					text = File.ReadString(outputFilePath&".txt","")
					IndexTxt(title, outputFilePath&".txt",text)
					versions.Put(title, NewDate)
					result="success"
				Else
					failedTimes=failedTimes+1
					logMap.Put(title,failedTimes)
					File.WriteMap(logPath,"",logMap)
					result="not supported"
				End If
			End If

		End If
		Main.esclient.Insert("meta", "dates", id, versions)
	End If
	Return result
End Sub


Private Sub IndexTxt (title As String,txtFilePath As String, text As String)
	Log("Indexing file: " & txtFilePath)

	Dim projectPath As String=File.GetFileParent(File.GetFileParent(txtFilePath))
	Dim categoryPath As String=File.GetFileParent(projectPath)
	Dim document As Map
	document=CreateMap( _
	"filename": File.GetName(txtFilePath), _
	"project": File.GetName(projectPath), _
	"category": File.GetName(categoryPath), _
	"text": text, _
	"title":File.GetName(title), _
	"sourceOrTarget":File.GetName(File.GetFileParent(txtFilePath)) _
	)
	Main.esclient.Insert("documents", "txt", "", document)
End Sub

