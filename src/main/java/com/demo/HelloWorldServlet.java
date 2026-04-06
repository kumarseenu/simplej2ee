package com.demo;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.Properties;

@WebServlet("/hello")
public class HelloWorldServlet extends HttpServlet {

    private String appVersion = "unknown";
    private String appCommit  = "unknown";

    @Override
    public void init() {
        Properties props = new Properties();
        try (InputStream is = getClass().getResourceAsStream("/version.properties")) {
            if (is != null) {
                props.load(is);
                appVersion = props.getProperty("app.version", "unknown");
                appCommit  = props.getProperty("app.commit",  "unknown");
            }
        } catch (IOException e) {
            // leave defaults
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = resp.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head><title>Hello World</title>");
            out.println("<style>body{font-family:sans-serif;max-width:600px;margin:60px auto;}");
            out.println(".version{background:#f0f4ff;border-left:4px solid #4a6fa5;padding:10px 16px;border-radius:4px;margin-top:24px;}");
            out.println(".commit{font-family:monospace;font-size:0.9em;color:#555;}</style>");
            out.println("</head><body>");
            out.println("<h1>Hello, World!</h1>");
            out.println("<p>Simple J2EE app running on Tomcat port 8070</p>");
            out.println("<div class='version'>");
            out.println("  <strong>Version:</strong> " + escapeHtml(appVersion) + "<br/>");
            out.println("  <strong>Commit:</strong> <span class='commit'>" + escapeHtml(appCommit) + "</span>");
            out.println("</div>");
            out.println("</body></html>");
        }
    }

    private String escapeHtml(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}
