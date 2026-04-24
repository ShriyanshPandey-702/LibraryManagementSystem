<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
<title>Library Login</title>
<style>
body{
font-family:Arial;
background:#f2f2f2;
text-align:center;
margin-top:100px;
}
.box{
width:300px;
margin:auto;
padding:30px;
background:white;
border-radius:10px;
box-shadow:0 0 10px gray;
}
input{
width:90%;
padding:10px;
margin:10px;
}
button{
padding:10px 20px;
background:#007bff;
color:white;
border:none;
}
</style>
</head>

<body>

<div class="box">
<h2>Library Login</h2>

<form action="../LoginServlet" method="post">

<input type="text" name="username" placeholder="Username" required>

<input type="password" name="password" placeholder="Password" required>

<button type="submit">Login</button>

</form>

</div>

</body>
</html>
