B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.7
@EndOfDesignText@
'Handler class
Sub Class_Globals
	
End Sub

Public Sub Initialize
	
End Sub

Sub Handle(req As ServletRequest, resp As ServletResponse)
	Dim QueryString As String = req.GetParameter("query")
	Dim searchType As String = req.GetParameter("type")
	Dim from As String = req.GetParameter("from")
	Dim category As String = req.GetParameter("category")
	Dim field As String = req.GetParameter("field")
	Dim sourceOrTarget As String= req.GetParameter("source_or_target")
	Dim fuzzy As String= req.GetParameter("fuzzy")
	Log(QueryString)
	
	If QueryString.StartsWith("+") Then
		fuzzy=""
		QueryString=QueryString.SubString(1)
	End If
	Log(QueryString)
	If from="" Then
		from=0
	End If
	
	If field="" Then
		field="text"
	End If
	
	Dim shouldConditions As List
	shouldConditions.Initialize
	Dim mustConditions As List
	mustConditions.Initialize
	
	If QueryString.Contains("*") Or QueryString.Contains("?") Then
		shouldConditions.Add(QueryDSLMaker.wildcardDict("title",QueryString))
		shouldConditions.Add(QueryDSLMaker.wildcardDict(field,QueryString))
	Else
		shouldConditions.Add(QueryDSLMaker.matchDict("title",QueryString,fuzzy))
		shouldConditions.Add(QueryDSLMaker.matchDict(field,QueryString,fuzzy))
	End If
	
	If category<> "" Then
		mustConditions.Add(QueryDSLMaker.matchDict("category",category,""))
	End If
	
	If sourceOrTarget<>"" Then
		mustConditions.Add(QueryDSLMaker.matchDict("sourceOrTarget",sourceOrTarget,""))
	End If
	


	
	Dim Query As Map
	If mustConditions.Size<>0 Then
		mustConditions.Add(QueryDSLMaker.boolDict("should",shouldConditions))
		Query = QueryDSLMaker.boolDict("must",mustConditions)
	Else
		Query = QueryDSLMaker.boolDict("should",shouldConditions)
	End If
	

    
	If QueryString = "" Then
		resp.SendError(500, "Missing query.")
		Return
	End If

	resp.ContentType = "application/json"
	resp.CharacterEncoding = "UTF-8"
	
	Log(Query)
	Dim esres As ESResponse
	
	If searchType="highlight" Then
		Dim Highlighter As Map = CreateMap( _
			"pre_tags": Array("<em>"), "post_tags": Array("</em>"), _
			"fields": CreateMap("title":CreateMap(),field: CreateMap()))
		esres = Main.esclient.Search("documents", "txt", _
			CreateMap("query": Query, _
		     "from":from, _
			 "highlight": Highlighter, _
	         "_source": Array("category","project","filename","title","sourceOrTarget")))
	Else
		esres = Main.esclient.Search("documents", "txt", _
			CreateMap("query": Query,"from":from))
	End If
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