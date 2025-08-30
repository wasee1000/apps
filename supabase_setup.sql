-- Indian TV Streaming App - Supabase Database Schema
-- This file contains all the SQL commands to set up the database structure

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE subscription_plan AS ENUM ('free', 'premium', 'trial');
CREATE TYPE content_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE download_status AS ENUM ('pending', 'downloading', 'completed', 'failed', 'expired');

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    icon_url TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shows table
CREATE TABLE shows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    banner_url TEXT,
    trailer_url TEXT,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    genre TEXT[] DEFAULT '{}',
    language TEXT DEFAULT 'hindi',
    rating DECIMAL(2,1) DEFAULT 0.0,
    total_episodes INTEGER DEFAULT 0,
    status content_status DEFAULT 'draft',
    is_premium BOOLEAN DEFAULT false,
    tags TEXT[] DEFAULT '{}',
    release_year INTEGER,
    director TEXT,
    cast TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Episodes table
CREATE TABLE episodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    show_id UUID REFERENCES shows(id) ON DELETE CASCADE,
    episode_number INTEGER NOT NULL,
    season_number INTEGER DEFAULT 1,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    video_url TEXT,
    video_duration INTEGER, -- in seconds
    file_size BIGINT, -- in bytes
    is_premium BOOLEAN DEFAULT false,
    is_trailer BOOLEAN DEFAULT false,
    status content_status DEFAULT 'draft',
    air_date TIMESTAMP WITH TIME ZONE,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(show_id, season_number, episode_number)
);

-- User profiles table (extends Supabase auth.users)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT,
    avatar_url TEXT,
    phone_number TEXT,
    date_of_birth DATE,
    preferred_language TEXT DEFAULT 'english',
    subscription_plan subscription_plan DEFAULT 'free',
    trial_start_date TIMESTAMP WITH TIME ZONE,
    trial_end_date TIMESTAMP WITH TIME ZONE,
    subscription_start_date TIMESTAMP WITH TIME ZONE,
    subscription_end_date TIMESTAMP WITH TIME ZONE,
    is_admin BOOLEAN DEFAULT false,
    notification_preferences JSONB DEFAULT '{"new_episodes": true, "recommendations": true, "subscription": true}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User watchlist table
CREATE TABLE user_watchlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    show_id UUID REFERENCES shows(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, show_id)
);

-- User favorites table
CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    episode_id UUID REFERENCES episodes(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, episode_id)
);

-- Watch history table
CREATE TABLE watch_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    episode_id UUID REFERENCES episodes(id) ON DELETE CASCADE,
    watch_progress INTEGER DEFAULT 0, -- in seconds
    watch_percentage DECIMAL(5,2) DEFAULT 0.0, -- percentage watched
    completed BOOLEAN DEFAULT false,
    last_watched TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_info JSONB,
    UNIQUE(user_id, episode_id)
);

-- Downloads table
CREATE TABLE downloads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    episode_id UUID REFERENCES episodes(id) ON DELETE CASCADE,
    download_quality TEXT DEFAULT '720p',
    download_status download_status DEFAULT 'pending',
    download_path TEXT,
    file_size BIGINT,
    downloaded_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, episode_id)
);

-- User ratings table
CREATE TABLE user_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    show_id UUID REFERENCES shows(id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, show_id)
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'general', -- general, new_episode, subscription, recommendation
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subscription transactions table
CREATE TABLE subscription_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    transaction_id TEXT UNIQUE,
    plan_type subscription_plan,
    amount DECIMAL(10,2),
    currency TEXT DEFAULT 'INR',
    payment_method TEXT,
    payment_status TEXT DEFAULT 'pending', -- pending, completed, failed, refunded
    payment_gateway TEXT, -- razorpay, paytm, etc.
    gateway_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content analytics table
CREATE TABLE content_analytics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    episode_id UUID REFERENCES episodes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- play, pause, seek, complete, quality_change
    event_data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    session_id UUID,
    device_info JSONB
);

-- Create indexes for better performance
CREATE INDEX idx_shows_category ON shows(category_id);
CREATE INDEX idx_shows_status ON shows(status);
CREATE INDEX idx_shows_premium ON shows(is_premium);
CREATE INDEX idx_episodes_show ON episodes(show_id);
CREATE INDEX idx_episodes_status ON episodes(status);
CREATE INDEX idx_episodes_premium ON episodes(is_premium);
CREATE INDEX idx_user_watchlist_user ON user_watchlist(user_id);
CREATE INDEX idx_user_favorites_user ON user_favorites(user_id);
CREATE INDEX idx_watch_history_user ON watch_history(user_id);
CREATE INDEX idx_watch_history_episode ON watch_history(episode_id);
CREATE INDEX idx_downloads_user ON downloads(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);
CREATE INDEX idx_content_analytics_episode ON content_analytics(episode_id);
CREATE INDEX idx_content_analytics_user ON content_analytics(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shows_updated_at BEFORE UPDATE ON shows FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_episodes_updated_at BEFORE UPDATE ON episodes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_watch_history_updated_at BEFORE UPDATE ON watch_history FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_ratings_updated_at BEFORE UPDATE ON user_ratings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscription_transactions_updated_at BEFORE UPDATE ON subscription_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to check if user has premium access
CREATE OR REPLACE FUNCTION has_premium_access(user_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_plan subscription_plan;
    trial_end TIMESTAMP WITH TIME ZONE;
    subscription_end TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT subscription_plan, trial_end_date, subscription_end_date
    INTO user_plan, trial_end, subscription_end
    FROM user_profiles
    WHERE id = user_uuid;
    
    -- Check if user has premium plan
    IF user_plan = 'premium' AND (subscription_end IS NULL OR subscription_end > NOW()) THEN
        RETURN TRUE;
    END IF;
    
    -- Check if user is in trial period
    IF user_plan = 'trial' AND trial_end > NOW() THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update show rating
CREATE OR REPLACE FUNCTION update_show_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE shows 
    SET rating = (
        SELECT ROUND(AVG(rating)::numeric, 1)
        FROM user_ratings 
        WHERE show_id = COALESCE(NEW.show_id, OLD.show_id)
    )
    WHERE id = COALESCE(NEW.show_id, OLD.show_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to update show rating when user rating changes
CREATE TRIGGER update_show_rating_trigger
    AFTER INSERT OR UPDATE OR DELETE ON user_ratings
    FOR EACH ROW EXECUTE FUNCTION update_show_rating();

-- Function to increment episode view count
CREATE OR REPLACE FUNCTION increment_view_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Only increment if watch percentage is greater than 10%
    IF NEW.watch_percentage > 10 AND (OLD.watch_percentage IS NULL OR OLD.watch_percentage <= 10) THEN
        UPDATE episodes 
        SET view_count = view_count + 1
        WHERE id = NEW.episode_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to increment view count
CREATE TRIGGER increment_view_count_trigger
    AFTER INSERT OR UPDATE ON watch_history
    FOR EACH ROW EXECUTE FUNCTION increment_view_count();

-- Insert default categories
INSERT INTO categories (name, description, icon_url, display_order) VALUES
('Drama', 'Family sagas, social dramas, and emotional stories', 'https://example.com/icons/drama.png', 1),
('Comedy', 'Light-hearted shows, sitcoms, and comedy series', 'https://example.com/icons/comedy.png', 2),
('Romance', 'Love stories and romantic dramas', 'https://example.com/icons/romance.png', 3),
('Mythology', 'Religious epics and mythological series', 'https://example.com/icons/mythology.png', 4),
('Reality', 'Reality shows, talent competitions, and game shows', 'https://example.com/icons/reality.png', 5);

-- Create a function to handle user profile creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_profiles (id, full_name)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile when user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

