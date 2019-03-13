B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=6.51
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

Sub read(path As String) As String
	Dim textContent As String
	Dim encoding As String
	encoding=icu4j.getEncoding(path,"")
	Dim textReader As TextReader
	textReader.Initialize2(File.OpenInput(path,""),encoding)
	textContent=textReader.ReadAll
	textReader.Close
    Return textContent
End Sub



