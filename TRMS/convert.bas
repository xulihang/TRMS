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
	Try
		resp.CharacterEncoding="UTF-8"
		resp.ContentType = "text/html"
		'resp.Write("converting...")
		Dim su As StringUtils
		Dim filename As String=su.DecodeUrl(req.GetParameter("filename"),"UTF8")
		Dim path As String
		Dim uploadedPath As String=File.Combine(File.DirApp,"uploaded")
		Dim convertedPath As String=File.Combine(File.DirApp,"converted")
		path=File.Combine(uploadedPath,filename)
		convertToXliff(resp,path,convertedPath,filename)
	Catch
		resp.SendError(500, LastException)
	End Try
	StartMessageLoop
End Sub

Sub convertToXliff(resp As ServletResponse,path As String,convertedPath As String,filename As String)
	wait for (tikal.extract("en","zh",path,convertedPath)) complete(result As Boolean)
	If result Then
		'resp.Write("<br/>Below is the extraced text.<br/>")
		Dim text As String
		text=xliffFilter.getText(File.Combine(convertedPath,filename&".xlf"))
		If filename.EndsWith(".pdf") Then
			text=Utils.removeLines(text)
		End If
		'Dim bytes() As Byte
		'bytes=text.GetBytes("UTF8")
		'File.WriteString(File.Combine(File.Combine(File.DirApp,"www"),"output"),filename&".txt",text)
		'resp.SendRedirect("/output/"&filename&".txt")
		text="<pre>"&text&"</pre>"
		resp.Write(text)
		'resp.OutputStream.WriteBytes(bytes,0,bytes.Length)
	Else
		resp.SendError(500, "Convert Failed")
	End If
	StopMessageLoop
End Sub