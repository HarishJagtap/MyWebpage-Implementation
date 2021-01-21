## Intro

This is my implementation of my <a href="https://github.com/HarishJagtap/MyWebpage">"MyWebpage project"</a>.
Using AWS for the implementation.

## Main Steps

Web client <-> Web server <-> Wsgi <-> Django

* Launch an EC2 instance
  * Use an Elastic IP (Static IP) to prevent IP address change when stopping/starting instance.
  * Add an SSH Inbound rule with "Your IP" as source to access it.
  * Add HTTP and HTTPS Inbound rules with "All" as source for web browsers to access it.
  * SSH into it, git clone the <a href="https://github.com/HarishJagtap/MyWebpage">"MyWebpage project"</a> in "/var/www/" directory.
  * Follow steps mentioned in <a href="https://github.com/HarishJagtap/MyWebpage">"MyWebpage project"</a> to setup the webpage.
  * Now intead of Django, use Gunicorn or Uwsgi for the Wsgi.
  * This completes (Wsgi <-> Django)
  
* Register Domain
  * Add Resource records to connect it with your instance.
  * This completes (Web client <-> Web server)

* Setup Nginx
  * Get TLS Certificate for the Domain and subdomains
  * Configure it for HTTPS communication by providing the Certificate.
  * Configure it to route all HTTP traffic to HTTPS.
  * Connect it with WSGI
  * This completes (Web server <-> Wsgi)
 
 ## Result
 <a href="https://www.harish-jagtap.com">Visit my page</a> to see the result.
