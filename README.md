# Lock' in - Work Under Pressure

Lock' in delivers timed audio reminders to boost your productivity. Simply set intervals, and the app announces the time—forcing you to make decisions faster and manage your time better.

Does time pressure help you work better? **This app is not for everyone** and that's fine! Lock' in targets those who thrive under deadlines. By announcing the current time at regular intervals, it creates a subtle pressure environment without being distracting.

When you know you have a limited timeframe, you'll:

- Make faster decisions instead of overthinking details
- Break through procrastination cycles
- Stay aware of passing time during deep work
- Complete tasks more efficiently with artificial urgency

Create multiple custom sessions with different intervals and durations for various tasks—whether you need a gentle reminder every 30 minutes or an aggressive 5-minute countdown to stay on track.

## Features

Lock' in features a clean, distraction-free interface in both light and dark modes. The app includes:

- Customizable time intervals for announcements (5, 10, 15 minutes, etc.)
- Adjustable session durations
- Clear voice announcements of the current time
- Multiple concurrent sessions for different projects

## Development

### Quick Start with Firebase Studio

The fastest way to work with the code is through Firebase Studio:

<a href="https://studio.firebase.google.com/import?url=https%3A%2F%2Fgithub.com%2Fflutter%2Fwebsite">
  <img
    height="32"
    alt="Open in Firebase Studio"
    src="https://cdn.firebasestudio.dev/btn/open_blue_32.svg">
</a>

Everything is pre-configured so you can start coding immediately.

### Local Development

For local development:
1. Clone the repository: 
   ```
   git clone https://github.com/totallynotdavid/android-lock-in
   ```

2. Navigate to the project directory and install dependencies:
   ```
   flutter pub get
   ```

3. Connect your Android device or start an emulator, then run:
   ```
   flutter run --machine -d android
   ```
   
   Alternatively, if using an emulator with a specific port:
   ```
   flutter run --machine -d localhost:5555
   ```

The main code is in [`lib/main.dart`](lib/main.dart), with dependencies listed in [`pubspec.yaml`](pubspec.yaml).

## Contributing

Contributions are welcome! Before submitting changes, ensure your code matches our style guidelines and passes all tests.
