# Indian TV Streaming App - Admin Guide

Welcome to the Indian TV Streaming App Admin Panel! This guide will help you manage content, users, and monitor the platform effectively.

## Table of Contents

1. [Getting Started](#getting-started)
   - [Accessing the Admin Panel](#accessing-the-admin-panel)
   - [Admin Roles and Permissions](#admin-roles-and-permissions)
   - [Dashboard Overview](#dashboard-overview)
2. [Content Management](#content-management)
   - [Managing Shows](#managing-shows)
   - [Managing Episodes](#managing-episodes)
   - [Managing Categories](#managing-categories)
   - [Content Approval Workflow](#content-approval-workflow)
3. [Video Management](#video-management)
   - [Uploading Videos](#uploading-videos)
   - [Video Processing](#video-processing)
   - [Video Quality and Formats](#video-quality-and-formats)
   - [Managing Video Storage](#managing-video-storage)
4. [User Management](#user-management)
   - [Viewing User Information](#viewing-user-information)
   - [Managing User Accounts](#managing-user-accounts)
   - [User Activity Monitoring](#user-activity-monitoring)
5. [Subscription Management](#subscription-management)
   - [Managing Subscription Plans](#managing-subscription-plans)
   - [Viewing Subscriber Information](#viewing-subscriber-information)
   - [Handling Subscription Issues](#handling-subscription-issues)
6. [Analytics and Reporting](#analytics-and-reporting)
   - [Content Performance](#content-performance)
   - [User Engagement](#user-engagement)
   - [Revenue Reports](#revenue-reports)
   - [Custom Reports](#custom-reports)
7. [System Settings](#system-settings)
   - [General Settings](#general-settings)
   - [Notification Settings](#notification-settings)
   - [Storage Settings](#storage-settings)
   - [Security Settings](#security-settings)
8. [Troubleshooting](#troubleshooting)
   - [Common Issues](#common-issues)
   - [Technical Support](#technical-support)

## Getting Started

### Accessing the Admin Panel

1. Open the Indian TV Streaming App
2. Log in with your admin credentials
3. Tap on your profile icon in the bottom right
4. Select "Admin Panel" from the menu
5. You will be redirected to the admin dashboard

Alternatively, you can access the admin panel directly at:
- Web: https://admin.indiantvapp.com
- Mobile: Use the separate "Indian TV Admin" app

### Admin Roles and Permissions

The admin panel has three role levels:

1. **Super Admin**
   - Full access to all features
   - Can create and manage other admin accounts
   - Can modify system settings
   - Can access financial data and reports

2. **Content Manager**
   - Can manage shows, episodes, and categories
   - Can upload and process videos
   - Can view basic analytics
   - Cannot access user data or financial information

3. **Support Admin**
   - Can view user information
   - Can manage user accounts
   - Can handle subscription issues
   - Cannot modify content or access financial data

### Dashboard Overview

The admin dashboard provides an overview of:
- Total shows and episodes
- Total users and subscribers
- Active users today
- New users today
- Revenue today
- Recent activities
- Popular content

Use the navigation menu on the left to access different sections of the admin panel.

## Content Management

### Managing Shows

**Adding a New Show**
1. Go to "Shows" in the navigation menu
2. Click "Add Show"
3. Fill in the show details:
   - Title
   - Description
   - Category
   - Cast and crew information
   - Release year
   - Language
   - Thumbnail image
   - Banner image
4. Set show attributes:
   - Premium status
   - Featured status
   - Age rating
5. Click "Save" to create the show

**Editing a Show**
1. Go to "Shows" in the navigation menu
2. Find the show you want to edit
3. Click the "Edit" button
4. Modify the show details
5. Click "Save" to update the show

**Deleting a Show**
1. Go to "Shows" in the navigation menu
2. Find the show you want to delete
3. Click the "Delete" button
4. Confirm the deletion
   - Note: This will also delete all episodes associated with the show

### Managing Episodes

**Adding a New Episode**
1. Go to "Shows" in the navigation menu
2. Find the show you want to add an episode to
3. Click "View Episodes"
4. Click "Add Episode"
5. Fill in the episode details:
   - Episode title
   - Description
   - Season number
   - Episode number
   - Duration
   - Thumbnail image
6. Set episode attributes:
   - Premium status
   - Featured status
7. Upload the video file (see [Uploading Videos](#uploading-videos))
8. Click "Save" to create the episode

**Editing an Episode**
1. Go to "Shows" in the navigation menu
2. Find the show containing the episode
3. Click "View Episodes"
4. Find the episode you want to edit
5. Click the "Edit" button
6. Modify the episode details
7. Click "Save" to update the episode

**Deleting an Episode**
1. Go to "Shows" in the navigation menu
2. Find the show containing the episode
3. Click "View Episodes"
4. Find the episode you want to delete
5. Click the "Delete" button
6. Confirm the deletion

### Managing Categories

**Adding a New Category**
1. Go to "Categories" in the navigation menu
2. Click "Add Category"
3. Fill in the category details:
   - Name
   - Description
   - Icon
   - Banner image
4. Click "Save" to create the category

**Editing a Category**
1. Go to "Categories" in the navigation menu
2. Find the category you want to edit
3. Click the "Edit" button
4. Modify the category details
5. Click "Save" to update the category

**Deleting a Category**
1. Go to "Categories" in the navigation menu
2. Find the category you want to delete
3. Click the "Delete" button
4. Confirm the deletion
   - Note: You cannot delete a category that has shows assigned to it

### Content Approval Workflow

For platforms with multiple content managers:

1. Content is submitted by content managers
2. Content enters "Pending Approval" status
3. Super Admin reviews the content
4. Content is either approved or rejected
5. If approved, content is published
6. If rejected, content is returned with feedback

To approve content:
1. Go to "Content Approval" in the navigation menu
2. Review pending content
3. Click "Approve" or "Reject"
4. Add comments if rejecting
5. Click "Submit"

## Video Management

### Uploading Videos

**Direct Upload**
1. Go to "Upload" in the navigation menu
2. Click "Upload Video"
3. Select the video file from your device
4. Select a thumbnail image or generate one from the video
5. Fill in the video details:
   - Title
   - Description
   - Show association
   - Premium status
6. Click "Upload" to start the upload process
7. Wait for the upload to complete and processing to finish

**Bulk Upload**
1. Go to "Upload" in the navigation menu
2. Click "Bulk Upload"
3. Prepare your CSV file with video details
4. Upload the CSV file and corresponding video files
5. Review the upload summary
6. Click "Start Bulk Upload"
7. Monitor the progress in the "Upload Queue"

### Video Processing

After upload, videos go through automatic processing:
1. **Transcoding**: Converting to multiple quality levels
2. **Thumbnail Generation**: If not provided
3. **Content Analysis**: For inappropriate content
4. **DRM Protection**: For premium content

To check processing status:
1. Go to "Upload" in the navigation menu
2. Click "Processing Queue"
3. View the status of each video
4. Click "View Details" for more information

### Video Quality and Formats

The platform supports the following video formats:
- MP4 (H.264)
- WebM (VP9)
- HLS for adaptive streaming

Videos are transcoded to multiple quality levels:
- 480p (SD)
- 720p (HD)
- 1080p (Full HD)

To change default quality settings:
1. Go to "Settings" in the navigation menu
2. Click "Video Settings"
3. Adjust the quality presets
4. Click "Save"

### Managing Video Storage

**Storage Overview**
1. Go to "Storage" in the navigation menu
2. View storage usage statistics
3. See breakdown by content type and quality

**Optimizing Storage**
1. Go to "Storage" in the navigation menu
2. Click "Optimization"
3. Choose from optimization options:
   - Remove unused videos
   - Compress older content
   - Adjust quality levels for older content
4. Click "Apply" to implement changes

## User Management

### Viewing User Information

1. Go to "Users" in the navigation menu
2. View the list of all users
3. Use filters to narrow down the list:
   - Subscription status
   - Registration date
   - Activity status
4. Click on a user to view detailed information:
   - Profile details
   - Subscription information
   - Watch history
   - Device information

### Managing User Accounts

**Editing User Information**
1. Go to "Users" in the navigation menu
2. Find the user you want to edit
3. Click the "Edit" button
4. Modify the user details
5. Click "Save" to update the user

**Suspending a User**
1. Go to "Users" in the navigation menu
2. Find the user you want to suspend
3. Click the "Suspend" button
4. Select the suspension reason and duration
5. Click "Confirm" to suspend the user

**Deleting a User**
1. Go to "Users" in the navigation menu
2. Find the user you want to delete
3. Click the "Delete" button
4. Confirm the deletion
   - Note: This action cannot be undone

### User Activity Monitoring

1. Go to "Users" in the navigation menu
2. Click "Activity Log"
3. View user activities:
   - Login events
   - Content views
   - Download activities
   - Subscription changes
4. Use filters to narrow down the activities
5. Export activity logs for further analysis

## Subscription Management

### Managing Subscription Plans

**Viewing Subscription Plans**
1. Go to "Subscriptions" in the navigation menu
2. Click "Plans"
3. View all available subscription plans

**Creating a New Plan**
1. Go to "Subscriptions" in the navigation menu
2. Click "Plans"
3. Click "Add Plan"
4. Fill in the plan details:
   - Name
   - Description
   - Price
   - Billing cycle
   - Features
   - Trial period
5. Click "Save" to create the plan

**Editing a Plan**
1. Go to "Subscriptions" in the navigation menu
2. Click "Plans"
3. Find the plan you want to edit
4. Click the "Edit" button
5. Modify the plan details
6. Click "Save" to update the plan

**Archiving a Plan**
1. Go to "Subscriptions" in the navigation menu
2. Click "Plans"
3. Find the plan you want to archive
4. Click the "Archive" button
5. Confirm the action
   - Note: Existing subscribers will not be affected

### Viewing Subscriber Information

1. Go to "Subscriptions" in the navigation menu
2. Click "Subscribers"
3. View the list of all subscribers
4. Use filters to narrow down the list:
   - Plan type
   - Subscription status
   - Billing cycle
5. Click on a subscriber to view detailed information:
   - Subscription details
   - Payment history
   - Plan changes

### Handling Subscription Issues

**Managing Payment Failures**
1. Go to "Subscriptions" in the navigation menu
2. Click "Payment Issues"
3. View users with payment failures
4. Take action:
   - Send payment reminder
   - Extend grace period
   - Cancel subscription

**Processing Refunds**
1. Go to "Subscriptions" in the navigation menu
2. Click "Refunds"
3. View refund requests
4. Review the request details
5. Approve or reject the refund
6. Add comments for the decision

**Subscription Adjustments**
1. Go to "Subscriptions" in the navigation menu
2. Click "Subscribers"
3. Find the subscriber
4. Click "Adjust Subscription"
5. Choose the adjustment type:
   - Extend subscription
   - Change plan
   - Apply discount
   - Cancel subscription
6. Enter the adjustment details
7. Click "Apply" to implement the changes

## Analytics and Reporting

### Content Performance

1. Go to "Analytics" in the navigation menu
2. Click "Content Performance"
3. View metrics for shows and episodes:
   - Views
   - Completion rate
   - Average watch time
   - Engagement score
4. Filter by:
   - Time period
   - Category
   - Premium status
5. Export reports in CSV or PDF format

### User Engagement

1. Go to "Analytics" in the navigation menu
2. Click "User Engagement"
3. View user engagement metrics:
   - Daily active users
   - Monthly active users
   - Session duration
   - Retention rate
4. View engagement by:
   - Device type
   - Location
   - Age group
   - Subscription type
5. Export reports in CSV or PDF format

### Revenue Reports

1. Go to "Analytics" in the navigation menu
2. Click "Revenue"
3. View revenue metrics:
   - Total revenue
   - Revenue by plan
   - New subscriptions
   - Churn rate
   - Average revenue per user
4. Filter by time period
5. View revenue forecasts
6. Export reports in CSV or PDF format

### Custom Reports

1. Go to "Analytics" in the navigation menu
2. Click "Custom Reports"
3. Click "Create Report"
4. Select metrics to include
5. Set filters and parameters
6. Choose visualization type
7. Save the report
8. Schedule automatic generation (optional)
9. Export or share the report

## System Settings

### General Settings

1. Go to "Settings" in the navigation menu
2. Click "General"
3. Configure:
   - App name
   - Logo
   - Contact information
   - Legal information
   - Terms of service
   - Privacy policy
4. Click "Save" to apply changes

### Notification Settings

1. Go to "Settings" in the navigation menu
2. Click "Notifications"
3. Configure:
   - Push notification templates
   - Email notification templates
   - Notification triggers
   - Notification frequency
4. Click "Save" to apply changes

### Storage Settings

1. Go to "Settings" in the navigation menu
2. Click "Storage"
3. Configure:
   - Storage providers
   - CDN settings
   - Cache settings
   - Retention policies
4. Click "Save" to apply changes

### Security Settings

1. Go to "Settings" in the navigation menu
2. Click "Security"
3. Configure:
   - Admin access controls
   - Two-factor authentication
   - Session timeout
   - IP restrictions
   - Audit logging
4. Click "Save" to apply changes

## Troubleshooting

### Common Issues

**Video Upload Failures**
- Check the file format and size
- Verify network connectivity
- Check storage capacity
- Try uploading in smaller chunks

**Content Not Appearing**
- Check if the content is approved
- Verify the publishing date
- Check category assignments
- Clear the CDN cache

**User Access Issues**
- Verify user subscription status
- Check device limitations
- Review IP restrictions
- Check for account suspensions

**Analytics Discrepancies**
- Check the date range
- Verify the data sources
- Clear analytics cache
- Rebuild analytics indexes

### Technical Support

If you encounter issues that you cannot resolve:

1. Go to "Help" in the navigation menu
2. Click "Support"
3. Fill out the support form with details about your issue
4. Attach relevant screenshots or logs
5. Submit the form

For urgent issues, contact:
- Email: admin-support@indiantvapp.com
- Phone: +91-XXX-XXX-XXXX (9 AM to 6 PM IST)

---

This guide is regularly updated to reflect the latest features and improvements to the admin panel. For the most recent version, please visit the admin documentation portal at https://admin.indiantvapp.com/docs.

