B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7
@EndOfDesignText@

Sub Process_Globals
	
End Sub

Sub stringToMap(jsonString As String) As Map
	Log(jsonString)
	Dim json As JSONParser
	json.Initialize(jsonString)
	Return json.NextObject
End Sub

Sub matchDict(field As String, queryString As String,fuzzy As String) As Map
	'{match:{field:querystring}}
	If fuzzy="enabled" Then
		Return CreateMap("fuzzy":CreateMap(field:queryString))
	Else
		Return CreateMap("match":CreateMap(field:queryString))
	End If
	
End Sub

Sub wildcardDict(field As String, queryString As String) As Map
	Return CreateMap("wildcard":CreateMap(field:queryString))
End Sub

Sub regexpDict(field As String, queryString As String) As Map
	Return CreateMap("regexp":CreateMap(field:queryString))
End Sub

Sub boolDict(boolType As String,conditions As List) As Map
	Return CreateMap("bool":CreateMap(boolType:conditions))
End Sub