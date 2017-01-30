<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "HelperClasses.*, java.util.*"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
 	<table style="width:100%" border="1">
		<h1>Found ${movieListSize} result(s). </h1>
		
		<%
		int size = (Integer)request.getAttribute("movieListSize");
		List<Movie> movieList = (List)request.getAttribute("movieList");
		for(int i = 0; i < size; ++i) {%>
		
		<tr>
			<td><%= movieList.get(i).id %></td>
			<td><a href="http://google.com"><%= movieList.get(i).title %></a></td>
			<td><%= movieList.get(i).year %></td>
			<td><%= movieList.get(i).director %></td>
			<td> <b>GENRES</b>
			<% int genre_size = movieList.get(i).genresInMovie.size();
				for(int j = 0; j < genre_size; ++j) { %>
					<p> <%= movieList.get(i).genresInMovie.get(j) %></p>
					<%}%>
			</td>
			
			<td> <b>STARS</b>
			<% int star_size = movieList.get(i).starsInMovie.size(); 
				for(int j = 0; j < star_size; ++j) {
				int id = movieList.get(i).starsInMovie.get(j).id;
				String first_name = movieList.get(i).starsInMovie.get(j).fn;
				String last_name = movieList.get(i).starsInMovie.get(j).ln;
				String dob = movieList.get(i).starsInMovie.get(j).dob;
				String photo_url = movieList.get(i).starsInMovie.get(j).photo_url;
				List<String> movie_list = movieList.get(i).starsInMovie.get(j).featuredMoviesTitle;
				request.getSession().setAttribute("movie_list",movie_list);
				
				%>
				<p> <a href="starinfo.jsp?fn=<%=first_name%>&ln=<%=last_name%>&id=<%=id%>&photo_url=<%=photo_url%>&dob=<%=dob%>"><%= first_name %> <%= last_name %> </a></p>
				<%}%>
			</td>
		</tr>
		<%}%>
	</table>
</body>
</html>