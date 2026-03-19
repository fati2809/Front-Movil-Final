# Configuración de Google Sign-In

## ⚠️ IMPORTANTE: Seguridad

Los archivos con credenciales de Google **NO están en el repositorio** por seguridad (están en `.gitignore`):

- `ios/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

**Archivos de ejemplo disponibles:**

- `ios/Runner/GoogleService-Info.plist.example`
- `android/app/google-services.json.example`

Después de descargar tus archivos reales desde Firebase/Google Cloud Console, renómbralos quitando el `.example`.

## ✅ Ya está instalado

- Dependencia `google_sign_in: ^6.2.1` ya agregada
- Código de autenticación implementado en `AuthController`
- Botón de Google agregado en `LoginView`

## 🔧 Configuración requerida

### Android

1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Crea un proyecto o selecciona uno existente
3. Habilita **Google+ API**
4. Ve a **Credenciales** > **Crear credenciales** > **ID de cliente de OAuth 2.0**
5. Selecciona **Aplicación de Android**
6. Obtén tu SHA-1 certificate fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copia el SHA-1 de la variante `debug`
7. Package name: Revisa tu `android/app/build.gradle.kts` (applicationId, probablemente algo como `com.mapposting.mobile`)
8. Descarga el archivo `google-services.json` y colócalo en `android/app/`
9. Agrega a `android/build.gradle.kts`:
   ```kotlin
   dependencies {
       classpath("com.google.gms:google-services:4.3.15")
   }
   ```
10. Agrega a `android/app/build.gradle.kts`:
    ```kotlin
    plugins {
        id("com.google.gms.google-services")
    }
    ```

### iOS

1. En Google Cloud Console, crea otro **ID de cliente de OAuth 2.0**
2. Selecciona **iOS**
3. Bundle ID: Revisa tu `ios/Runner.xcodeproj` (probablemente algo como `com.mapposting.mobile`)
4. Descarga el archivo `GoogleService-Info.plist`
5. Abre Xcode: `open ios/Runner.xcworkspace`
6. Arrastra `GoogleService-Info.plist` al proyecto Runner
7. En `Info.plist`, agrega:
   ```xml
   <key>GIDClientID</key>
   <string>TU_CLIENT_ID_IOS</string>
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>TU_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```
   (Reemplaza con los valores de tu `GoogleService-Info.plist`)

## 🧪 Prueba sin backend

El código tiene un fallback que permite probar Google Sign-In localmente aunque el backend no tenga aún el endpoint `/login/google`:

- Verás la cuenta de Google en consola
- Mostrará un warning diciendo que el backend no respondió
- Puedes comentar el código del try-catch para simular login exitoso

## 🔗 Backend (opcional)

Si quieres conectar con el backend, necesitas crear en FastAPI:

```python
@router.post("/login/google")
async def google_login(id_token: str):
    # Verificar el id_token con Google o Supabase Auth
    # Retornar el mismo formato que /login:
    # { "success": True, "message": "...", "user": {...}, "session": {...} }
```

## 📱 Comandos útiles

```bash
# Ejecutar en Android
flutter run

# Ejecutar en iOS (requiere Mac + Xcode)
flutter run -d ios

# Limpiar si hay problemas
flutter clean && flutter pub get
cd android && ./gradlew clean && cd ..
```
