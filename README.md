# Indian TV Streaming App

A comprehensive mobile application for streaming Indian TV serials, daily soaps, and reality shows with subscription plans, admin video management, and modern UI/UX.

![App Banner](docs/images/app_banner.png)

## Features

### User Features
- **Content Streaming**: Watch full episodes, trailers, and exclusive content
- **Categories**: Browse content by Drama, Comedy, Romance, Mythology, Reality
- **Search**: Find shows and episodes with powerful search functionality
- **User Authentication**: Login/signup via Supabase with email and social options
- **Subscription Plans**: Free, paid, and 7-day free trial options
- **Offline Viewing**: Download episodes for offline watching
- **Watchlist**: Save favorite shows and episodes
- **Personalized Recommendations**: Get content suggestions based on watch history
- **Multi-language Support**: Interface and content in multiple Indian languages
- **Adaptive Streaming**: Optimized playback based on network conditions
- **Dark Mode**: Toggle between light and dark themes

### Admin Features
- **Video Management**: Upload, edit, and remove videos
- **Content Organization**: Manage shows, episodes, and categories
- **User Management**: View and manage user accounts
- **Analytics Dashboard**: Track views, engagement, and revenue
- **Subscription Management**: Configure plans and monitor subscribers
- **Content Approval Workflow**: Review and approve new content

## Technology Stack

- **Frontend**: Flutter for cross-platform mobile app
- **Backend**: Supabase for authentication, database, and storage
- **Video Streaming**: Adaptive streaming with HLS
- **Authentication**: Supabase Auth with JWT
- **Database**: PostgreSQL via Supabase
- **Storage**: Supabase Storage with CDN integration
- **Serverless Functions**: Supabase Edge Functions
- **CI/CD**: GitHub Actions for automated testing and deployment

## Project Structure

```
indian_tv_streaming_app/
├── mobile_app/               # Flutter mobile application
│   ├── lib/                  # Dart source code
│   │   ├── core/             # Core utilities and services
│   │   ├── features/         # Feature modules
│   │   └── main.dart         # Application entry point
│   ├── test/                 # Unit and widget tests
│   └── integration_test/     # Integration tests
├── backend/                  # Supabase backend configuration
│   ├── supabase_setup.sql    # Database schema
│   ├── rls_policies.sql      # Row Level Security policies
│   └── edge_functions/       # Serverless functions
├── docs/                     # Documentation
│   ├── architecture.md       # System architecture
│   ├── features.md           # Feature specifications
│   ├── user_guide.md         # User documentation
│   ├── admin_guide.md        # Admin documentation
│   └── deployment_guide.md   # Deployment instructions
└── .github/                  # GitHub configuration
    └── workflows/            # CI/CD workflows
```

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Node.js (16.0.0 or higher)
- Supabase CLI
- Git

### Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/indian_tv_streaming_app.git
cd indian_tv_streaming_app
```

#### 2. Set Up Supabase Backend

1. Create a new Supabase project from the [Supabase Dashboard](https://app.supabase.io/)
2. Apply the database schema:

```bash
cd backend
supabase login
supabase link --project-ref <your-project-id>
supabase db push
```

3. Deploy the edge functions:

```bash
cd backend/edge_functions
supabase functions deploy video-upload-handler
supabase functions deploy subscription-webhook
supabase functions deploy notification-sender
supabase functions deploy content-recommendation
```

#### 3. Configure Environment Variables

Create a `.env` file in the `mobile_app` directory:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_URL=https://your-project-id.supabase.co/rest/v1
STORAGE_URL=https://your-project-id.supabase.co/storage/v1
```

#### 4. Install Dependencies and Run the App

```bash
cd mobile_app
flutter pub get
flutter run
```

### Running Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test
```

## Deployment

See the [Deployment Guide](docs/deployment_guide.md) for detailed instructions on deploying the app to production environments.

## Documentation

- [System Architecture](docs/architecture.md)
- [Feature Specifications](docs/features.md)
- [User Guide](docs/user_guide.md)
- [Admin Guide](docs/admin_guide.md)
- [Deployment Guide](docs/deployment_guide.md)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Supabase](https://supabase.io/)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [Video Player](https://pub.dev/packages/video_player)
- [Flutter Stripe](https://pub.dev/packages/flutter_stripe)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Cached Network Image](https://pub.dev/packages/cached_network_image)

## Contact

For questions or support, please contact:
- Email: support@indiantvapp.com
- Website: www.indiantvapp.com

