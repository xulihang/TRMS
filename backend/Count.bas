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
	Dim field As String = req.GetParameter("field")
	resp.ContentType = "application/json"
	resp.CharacterEncoding = "UTF-8"
	Dim query As String
	query=$"{
	"size" : 0 ,
    "aggs" : {
        "categories" : {
            "terms" : { "field" : "${field}.keyword" }
        }
    }
}"$
	Log(query)
	Dim esres As ESResponse
	esres = Main.esclient.Search("documents", "txt", QueryDSLMaker.stringToMap(query))
	Dim json As JSONGenerator
	json.Initialize(esres.ResponseAsMap)
	resp.Write(json.ToString)
End Sub