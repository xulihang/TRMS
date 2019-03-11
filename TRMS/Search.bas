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
	If QueryString = "" Then
		resp.SendError(500, "Missing query.")
		Return
	End If
	Log(QueryString)
	resp.ContentType = "text/html"
	Dim Query As Map = CreateMap("simple_query_string": _
		CreateMap( _
			"fields": Array("text","title"), _
			"query": QueryString))
	
	Dim Highlighter As Map = CreateMap( _
		"pre_tags": Array("<b>"), "post_tags": Array("</b>"), _
		"fields": CreateMap("text": CreateMap(),"title": CreateMap()))
	'count the number of total results grouped by product.
	'https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html
	'(we need to use product.keyword instead of product because we are using the default mapping)

	Dim esres As ESResponse = Main.esclient.Search("main", "txt", _
		CreateMap("query": Query, _
		 "highlight": Highlighter, _
         "_source": "title"))
    Log("hits"&esres.Hits)
	If esres.Hits.Size = 0 Then
		resp.Write("No match found!")
	Else
		Log(esres.ResponseAsMap)
		Dim sb As StringBuilder
		sb.Initialize
		sb.Append("<p>")
		'get the aggregation result
		sb.Append("<ul>")
		For Each hits As Map In esres.Hits
			sb.Append("<li>")
			Dim source As Map = hits.Get("_source")
			sb.Append(source.Get("title"))
			sb.Append("<ul>")
			Dim Highlight As Map
			Highlight=hits.Get("highlight")
			
			Dim textList As List=Highlight.Get("text")
			For Each text In textList
				sb.Append("<li>")
				text=Regex.replace("\n{2,}",text,"<br/>")
				sb.Append(text).Append("<br/>")
				sb.Append("</li>")
			Next
			sb.Append("</ul>")
			sb.Append("</li>")
		Next
		sb.Append("</ul>")
		sb.Append("</p>")
		resp.Write(sb.ToString)
	End If
End Sub