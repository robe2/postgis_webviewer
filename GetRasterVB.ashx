<%@ WebHandler Language="VB" Class="GetRasterVB" %>
'-- Author: Regina Obe (Paragon Corporation) lr@pcorp.us
'-- PostGIS in Action: http://www.postgis.us
'-- Released under the MIT
'-- Version: 0.2
Imports System
Imports System.Web
Imports Npgsql

Public Class GetRasterVB : Implements IHttpHandler
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "image/png"
        
        If Not IsNothing(context.Request("sql")) Then
            context.Response.BinaryWrite(GetResults(context, context.Request("sql"), context.Request("bvals"), context.Request("spatial_type")))
        Else
            context.Response.BinaryWrite(GetResults(context, "ST_Buffer(ST_Point(1,2),10)", "10,100,10", "geometry"))
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
    Public Function GetResults(context As HttpContext, ByVal aquery As String, bvals As String, spatial_type As String) As Byte()
        Dim result As Byte()
        Dim command As NpgsqlCommand
        Dim geomtext As String = "ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,1)"
        Dim arybvals As String() = bvals.Split(",")
        
        'Dim nParam As NpgsqlParameter = New Npgsql.NpgsqlParameter(
        Dim sql As String
        Using conn As NpgsqlConnection = New NpgsqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("DSN").ConnectionString)
            conn.Open()
            If aquery.Trim().Length > 0 Then
                geomtext = aquery
            End If
            If spatial_type = "raster" Or spatial_type = "raw" Then
                sql = "SELECT postgis_viewer_image(:spatial_expression, :spatial_type)" 'for raster color values are encoded in the raster
            Else
                sql = "SELECT postgis_viewer_image(:spatial_expression, :spatial_type, :color)"
            End If
        

            command = New NpgsqlCommand(sql, conn)
            
            command.Parameters.Add(New NpgsqlParameter("spatial_expression", aquery))
            command.Parameters.Add(New NpgsqlParameter("spatial_type", spatial_type))
            
            If spatial_type = "geometry" Then
                command.Parameters.Add(New NpgsqlParameter("color", New Integer() {arybvals(0), arybvals(1), arybvals(2)}))
            End If

            Try
                result = command.ExecuteScalar()
            Catch ex As Exception
                result = Nothing
                context.Response.Write(ex.Message.Trim)
            End Try
            conn.Close()

        End Using
        Return result
    End Function

End Class

