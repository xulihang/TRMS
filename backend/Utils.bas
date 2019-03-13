B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7
@EndOfDesignText@

Sub Process_Globals
	
End Sub

Sub getExtension(filename As String) As String
	Try
		Return filename.SubString2(filename.LastIndexOf(".")+1,filename.Length)
	Catch
		Log(LastException)
		Return ""
	End Try
End Sub

Sub removeLines(input As String) As String
	Dim result As String
	Dim list1 As List
	list1.Initialize
	list1.AddAll(Regex.Split(CRLF,input))
	Log(list1)
	For Each line As String In list1

		line=line.Trim

		Log(line)

		If line="" Or line=" " Then

			Continue

		End If

		If isSentenceEnd(line)=False Then

			result=result&" "&line

		Else

			result=result&" "&line&CRLF

		End If

	Next

	Dim list2 As List

	list2.Initialize

	list2.AddAll(Regex.Split(CRLF,result))
	result=""
	For Each line As String In list2
		result=result&line.Trim&CRLF&CRLF
	Next
	Return result
End Sub


Sub isSentenceEnd(line As String) As Boolean
	If line.EndsWith(".") Or line.EndsWith("!") Or line.EndsWith("?") Or line.EndsWith(";") Or line.EndsWith(Chr(34)) Or line.EndsWith("！") Or line.EndsWith("”") Or line.EndsWith("？") Or line.EndsWith("。") Then
		Return True
	Else
		Return False
	End If
End Sub