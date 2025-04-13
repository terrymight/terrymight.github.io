---
title: "Resolving CORS Issues in Laravel Sanctum on Shared Hosting"
description: "Hosting a Laravel application with Sanctum for API authentication on shared hosting can be challenging, especially when integrating a frontend on a different subdomain."
date: "2025-04-13T20:04:31+01:00"
publishDate: "2025-04-13T20:04:31+01:00"
tags: ["PHP", "LARAVEL"]
categories: ["PHP"]
authors: ["Tejiri Mayone"]
---

{{< figure src="/post/images/web-api-cors.png" caption="cors error with santum laravel PHP framework" >}}
<!--more-->

Hosting a [Laravel application](https://laravel.com/docs/12.x) with Sanctum for API authentication on shared hosting can be challenging, especially when integrating a frontend on a different subdomain. This article explains how to configure Laravel Sanctum to handle [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS#the_http_response_headers) correctly, using a real-world example with the following `.env` settings:

```plaintext
APP_URL=https://api.weburladdr.com
FRONTEND_URL=https://app.weburladdr.com
SANCTUM_STATEFUL_DOMAINS=https://app.weburladdr.com
SESSION_DOMAIN=.weburladdr.com
SESSION_SECURE_COOKIE=true
SESSION_DRIVER=cookie
```

We’ll dive into a common [CORS error](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS#the_http_response_headers), its causes, and a step-by-step solution tailored for shared hosting environments, ensuring secure API communication between `https://api.weburladdr.com` (backend) and `https://app.weburladdr.com` (frontend).

## The Problem: CORS Error

When the frontend at `https://app.weburladdr.com` attempts to call the backend’s `/login` endpoint (`https://api.weburladdr.com/login`), you might encounter:

> Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at https://api.weburladdr.com/login. (Reason: CORS header ‘Access-Control-Allow-Origin’ does not match ‘https://app.weburladdr.com/’).

This error occurs because the browser’s Same Origin Policy restricts cross-origin requests unless the server explicitly allows the frontend’s origin via CORS headers (`Access-Control-Allow-Origin`). In this case, Laravel Sanctum’s configuration needs adjustment to permit `https://app.weburladdr.com` for stateful API requests.

## Understanding the `.env` Configuration

Let’s break down the provided `.env` settings and their roles:

- **APP_URL=https://api.weburladdr.com**: Defines the backend’s base URL. Using `https://` ensures SSL compliance, critical for secure cookie handling.
- **FRONTEND_URL=https://app.weburladdr.com**: A custom variable, often used in the app to reference the frontend. It’s not directly tied to CORS but helps with URL generation.
- **SANCTUM_STATEFUL_DOMAINS=https://app.weburladdr.com**: Specifies domains allowed for stateful (cookie-based) Sanctum requests. This is key to setting the `Access-Control-Allow-Origin` header.
- **SESSION_DOMAIN=.weburladdr.com**: Allows cookies to be shared across subdomains (`api.weburladdr.com`, `app.weburladdr.com`), enabling seamless session management.
- **SESSION_SECURE_COOKIE=true**: Ensures cookies are sent over HTTPS only, enhancing security.
- **SESSION_DRIVER=cookie**: Uses cookies for session storage, suitable for Sanctum’s stateful authentication.

The CORS error suggests that `SANCTUM_STATEFUL_DOMAINS` or related CORS settings aren’t fully aligned, causing a mismatch in the `Access-Control-Allow-Origin` header.

## Step-by-Step Solution

Here’s how to resolve the CORS issue on a shared hosting setup (e.g., with a Laravel project in `/home/ourlordisgreat/laravel_server/` and public files in `/home/ourlordisgreat/public_html/api.weburladdr.com/`).

### 1. Verify `.env` Settings

Ensure the `.env` file is correct and includes the protocol (`https://`) for all URLs:

```plaintext
APP_URL=https://api.weburladdr.com
FRONTEND_URL=https://app.weburladdr.com
SANCTUM_STATEFUL_DOMAINS=https://app.weburladdr.com
SESSION_DOMAIN=.weburladdr.com
SESSION_SECURE_COOKIE=true
SESSION_DRIVER=cookie
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
```

After updating `.env`, clear the configuration cache:

```bash
cd /home/ourlordisgreat/laravel_server
php artisan config:cache
php artisan cache:clear
```

### 2. Configure Laravel Sanctum

Sanctum handles CORS for stateful requests. Update the Sanctum configuration in `config/sanctum.php`:

```php
return [
    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'https://app.weburladdr.com')),
    'guard' => ['web'],
    'expiration' => null,
    'middleware' => [
        'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
        'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
    ],
];
```

- `'stateful'`: Ensures `https://app.weburladdr.com` is allowed for cookie-based requests.

### 3. Set Up CORS Configuration

Laravel uses the `fruitcake/laravel-cors` package or built-in CORS middleware for stateless API requests. Update `config/cors.php`:

```php
return [
    'paths' => ['api/*', 'sanctum/*', 'login', 'logout', 'register'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [env('FRONTEND_URL', 'https://app.weburladdr.com')],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

- `paths`: Covers Sanctum routes (`sanctum/*`) and authentication endpoints (`login`, `logout`).
- `allowed_origins`: Explicitly allows `https://app.weburladdr.com`.
- `supports_credentials`: Set to `true` for Sanctum’s cookie-based authentication.

### 4. Verify Middleware

Ensure Sanctum’s middleware is applied in `app/Http/Kernel.php`:

```php
protected $middlewareGroups = [
    'web' => [
        \App\Http\Middleware\EncryptCookies::class,
        \Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse::class,
        \Illuminate\Session\Middleware\StartSession::class,
        \Illuminate\View\Middleware\ShareErrorsFromSession::class,
        \App\Http\Middleware\VerifyCsrfToken::class,
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
    'api' => [
        \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        'throttle:api',
        \Illuminate\Routing\Middleware\SubstituteBindings::class,
    ],
];
```

The `EnsureFrontendRequestsAreStateful` middleware checks `SANCTUM_STATEFUL_DOMAINS` and sets CORS headers for stateful requests.

### 5. Update Frontend Requests

The frontend must handle Sanctum’s CSRF and cookie requirements. If using Axios (e.g., in a Vue/React app):

```javascript
// Set withCredentials for cookies
axios.defaults.withCredentials = true;

// Fetch CSRF token before POST requests
axios.get('https://api.weburladdr.com/sanctum/csrf-cookie').then(() => {
    axios.post('https://api.weburladdr.com/login', {
        email: 'user@example.com',
        password: 'password',
    }).then(response => {
        console.log('Login successful:', response);
    }).catch(error => {
        console.error('Login failed:', error);
    });
});
```

- `withCredentials: true`: Sends cookies (e.g., `XSRF-TOKEN`, `laravel_session`).
- `/sanctum/csrf-cookie`: Sets the CSRF token before POST requests like `/login`.

### 6. Configure Shared Hosting

Shared hosting environments require additional checks:

- **SSL**: Ensure `https://api.weburladdr.com` has a valid SSL certificate (via cPanel’s **Let’s Encrypt**). Force HTTPS in `.htaccess` (`/home/ourlordisgreat/public_html/api.weburladdr.com/public/.htaccess`):

  ```apache
  <IfModule mod_rewrite.c>
      RewriteEngine On
      RewriteCond %{HTTPS} off
      RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteCond %{REQUEST_FILENAME} !-d
      RewriteRule ^(.*)$ index.php/$1 [L]
  </IfModule>
  ```

- **Storage Symlink**: If serving public files (e.g., uploads), verify the symlink:

  ```bash
  ls -l /home/ourlordisgreat/public_html/api.weburladdr.com/storage
  ```

  Should point to `/home/ourlordisgreat/laravel_server/storage/app/public/`. Recreate if needed:

  ```bash
  rm -rf /home/ourlordisgreat/public_html/api.weburladdr.com/storage
  ln -s /home/ourlordisgreat/laravel_server/storage/app/public /home/ourlordisgreat/public_html/api.weburladdr.com/storage
  ```

- **Permissions**: Set secure permissions:

  ```bash
  chmod -R 775 /home/ourlordisgreat/laravel_server/storage
  chmod -R 775 /home/ourlordisgreat/laravel_server/bootstrap/cache
  chmod -R 755 /home/ourlordisgreat/public_html/api.weburladdr.com/public
  chown -R www-data:www-data /home/ourlordisgreat/laravel_server
  chown -R www-data:www-data /home/ourlordisgreat/public_html/api.weburladdr.com
  ```

  Replace `www-data` with your server’s web user if different.

- **Database**: Ensure migrations are applied without errors (addressing prior `users` table issues):

  ```bash
  mysql -u your_username -p -e "DROP TABLE users, password_reset_tokens, sessions;" your_database_name
  cd /home/ourlordisgreat/laravel_server
  php artisan migrate:fresh --force
  ```

### 7. Test the Setup

1. **Clear Caches**:

   ```bash
   php artisan config:cache
   php artisan cache:clear
   php artisan route:cache
   ```

2. **Verify CORS Headers**:

   ```bash
   curl -I -X OPTIONS https://api.weburladdr.com/login
   ```

   Look for:

   ```
   Access-Control-Allow-Origin: https://app.weburladdr.com
   Access-Control-Allow-Credentials: true
   ```

3. **Test Login**:

   From the frontend (`https://app.weburladdr.com`), trigger a login request. Use browser Dev Tools (Network tab) to confirm:

   - Request to `https://api.weburladdr.com/sanctum/csrf-cookie` sets cookies.
   - POST to `/login` returns 200 OK or expected response.
   - Headers include `Access-Control-Allow-Origin: https://app.weburladdr.com`.

4. **Check Logs**:

   If errors persist, inspect:

   ```bash
   cat /home/ourlordisgreat/laravel_server/storage/logs/laravel.log
   ```

## Troubleshooting Tips

If the CORS error remains, consider:

- **Incorrect Origin**: Double-check `SANCTUM_STATEFUL_DOMAINS` includes the exact frontend URL, including protocol and port (e.g., `https://app.weburladdr.com:443` if non-standard).
- **Middleware Order**: Ensure `EnsureFrontendRequestsAreStateful` runs before other API middleware.
- **Shared Hosting Limits**: Some hosts block CORS headers via ModSecurity. Contact support to whitelist `https://app.weburladdr.com`.
- **Frontend Misconfiguration**: Verify the frontend sends `withCredentials: true` and fetches the CSRF token.
- **Debug Mode**: Temporarily set `APP_DEBUG=true` in `.env` to view detailed errors, then revert to `false`.

## Additional Security Considerations

- **Protect `.env`**:

  ```bash
  chmod 600 /home/ourlordisgreat/laravel_server/.env
  ```

  Add to `.htaccess` in `/home/ourlordisgreat/laravel_server/`:

  ```apache
  <Files .env>
      Order allow,deny
      Deny from all
  </Files>
  ```

- **Use Strong Credentials**: Secure MySQL, SSH, and SFTP access (avoid FTP due to prior `530` errors).
- **Regular Backups**: Use cPanel’s **Backup Wizard** to save files and databases.
- **Monitor Logs**: Check `/home/ourlordisgreat/laravel_server/storage/logs/` for suspicious activity.

## Conclusion

Configuring Laravel Sanctum for CORS on shared hosting requires precise `.env` settings, Sanctum and CORS configuration, and frontend adjustments. By setting `SANCTUM_STATEFUL_DOMAINS=https://app.weburladdr.com`, updating `config/cors.php`, and ensuring proper middleware, you can resolve the CORS error and enable secure communication between `https://api.weburladdr.com` and `https://app.weburladdr.com`. Shared hosting adds complexity, but with careful file permissions, SSL enforcement, and symlink management, your Laravel API can run smoothly.

For further issues, verify logs, test headers, and consult your hosting provider for server-specific quirks. Happy coding!

---

*Tags*: Laravel, Sanctum, CORS, Shared Hosting, API Authentication, Cross-Origin
```