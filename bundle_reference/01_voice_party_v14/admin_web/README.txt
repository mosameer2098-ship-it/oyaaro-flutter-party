cPanel par upload:
1. config.js mein apne Firebase web app ki values daalein.
2. Ye poora admin_web folder cPanel ke public_html/admin/ mein upload karein (File Manager ya FTP).
3. Firebase Console > Authentication > Settings > Authorized domains mein apna domain add karein.
4. https://yourdomain.com/admin/ kholein, admin account se login karein.

Security: panel sirf static HTML/JS hai. Data ko Firebase rules aur admin role protect karte hain.
Is folder mein koi service account key ya secret nahi hona chahiye.
