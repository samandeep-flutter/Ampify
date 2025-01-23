# ![App Icon](https://github.com/samanjhutty/ampify/blob/main/android/app/src/main/res/mipmap-hdpi/ic_launcher.png) Ampify

![Version](https://img.shields.io/github/v/release/samanjhutty/ampify)
![License](https://img.shields.io/github/license/samanjhutty/ampify)
![repo size](https://img.shields.io/github/repo-size/samanjhutty/ampify)
![Release Date](https://img.shields.io/github/release-date/samanjhutty/ampify)

**Ampify: Turn Up the Volume on Your Music Journey!**

Ampify enhances your Spotify experience by providing smarter playlist management, music discovery, and personalized features—all designed to amplify your listening journey.

## Features

- **Listen History**: Rediscover your favorite tracks with a curated view of your listening activity.
- **Advanced Search**: Find tracks, artists, and playlists effortlessly.
- **Personalized Enhancements**: Take your Spotify experience to the next level with unique features.

## Getting Started

### Prerequisites

- A Spotify account
- Internet connectivity

### Setting Up Spotify App

1. Go to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/).
2. Log in with your Spotify account and create a new app.
3. Provide the necessary details (e.g., App Name, Description) and click **Create**.
4. Note down the **Client ID** and **Client Secret**.
5. Add your app's redirect URL (e.g., `<APPNAME/UNIQUE-APP-NAME>://<REDIECT-LINK>`) in the app settings under **Redirect URIs**.

### Configuring Environment Variables

1. Create a `.env` file in the root directory of your project.
2. Add the following keys to the `.env` file:

   ```env
   SPOTIFY_CLIENT_ID=<your-client-id>
   SPOTIFY_CLIENT_SECRET=<your-client-secret>
   SPOTIFY_REDIRECT_URL=<APPNAME/UNIQUE-APP-NAME>://<REDIECT-LINK>
   ```

### Configuring App Links

#### iOS (Info.plist)

1. Open your `Info.plist` file.
2. Add the following under `<dict>`:

   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string> `<APPNAME/UNIQUE-APP-NAME>` </string>
           </array>
       </dict>
   </array>
   ```

3. Add the following key for Universal Links:

   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

#### Android (AndroidManifest.xml)

1. Open your `AndroidManifest.xml` file.
2. Add the following inside the `<application>` tag:

   ```xml
   <activity>
       <intent-filter android:autoVerify="true">
           <action android:name="android.intent.action.VIEW" />
           <category android:name="android.intent.category.DEFAULT" />
           <category android:name="android.intent.category.BROWSABLE" />
           <data android:scheme="<APPNAME/UNIQUE-APP-NAME>" android:host="<REDIECT-LINK>" />
       </intent-filter>
   </activity>
   ```

## How to Use

1. **Log In**: Connect your Spotify account through the secure login process.
2. **Explore Features**: Use search, view your listening history, and enjoy enhanced playlist tools.
3. **Log Out**: Securely log out anytime, but remember you'll need to reconnect to use the app again.

## Support

If you encounter any issues, feel free to reach out to my [email](mailto:samandeep.flutterdev@gmail.com).

## License

This project is licensed under the MIT License.
