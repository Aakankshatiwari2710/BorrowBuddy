<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error | ShareSphere</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #14b8a6;
            --bg: #f8fafc;
        }
        body {
            font-family: 'Outfit', sans-serif;
            background: var(--bg);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            text-align: center;
        }
        .container {
            max-width: 500px;
            padding: 40px;
            background: #fff;
            border-radius: 30px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.05);
        }
        h1 { font-size: 80px; margin: 0; color: var(--primary); }
        h2 { font-size: 24px; color: #1e293b; margin: 10px 0; }
        p { color: #64748b; line-height: 1.6; margin-bottom: 30px; }
        .btn {
            background: var(--primary);
            color: white;
            text-decoration: none;
            padding: 15px 30px;
            border-radius: 50px;
            font-weight: 700;
            transition: 0.3s;
            display: inline-block;
        }
        .btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(20, 184, 166, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Oops!</h1>
        <h2>Something went wrong.</h2>
        <p>The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
        <a href="home.jsp" class="btn">Back to Home</a>
    </div>
</body>
</html>
