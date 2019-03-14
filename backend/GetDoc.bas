B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7
@EndOfDesignText@
'Handler class
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Dim category As String = req.GetParameter("category")
	Dim project As String = req.GetParameter("project")
	Dim filename As String = req.GetParameter("filename")
	Dim mustConditions As List
	mustConditions.Initialize
	
	If category<> "" Then
		mustConditions.Add(QueryDSLMaker.matchDict("category",category,""))
	End If
	
	If project<>"" Then
		mustConditions.Add(QueryDSLMaker.matchDict("project",project,""))
	End If
	
	If filename<> "" Then
		mustConditions.Add(QueryDSLMaker.matchDict("filename",filename,""))
	End If
	
	Dim Query As Map
	If mustConditions.Size<>0 Then
		Query = QueryDSLMaker.boolDict("must",mustConditions)
	Else
		resp.SendError(500,"Incomplete params")
		Return
	End If
	
	resp.ContentType = "application/json"
	resp.CharacterEncoding = "UTF-8"
	
	Log(Query)
	Dim esres As ESResponse
	

	esres = Main.esclient.Search("documents", "txt", _
		CreateMap("query": Query))

	If esres.Hits.Size = 0 Then
		resp.Write("No match found!")
	Else
		Log(esres.Hits)
		Dim json As JSONGenerator
		'json.Initialize(esres.ResponseAsMap)
		json.Initialize2(esres.Hits)
		resp.Write(json.ToPrettyString(4))
	End If
End Sub