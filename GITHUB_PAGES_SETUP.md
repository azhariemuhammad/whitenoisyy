# GitHub Pages Setup Instructions

This repository is now configured to automatically deploy to GitHub Pages using GitHub Actions.

## What Was Added

A GitHub Actions workflow (`.github/workflows/deploy.yml`) has been created that will:
- Automatically deploy the website when changes are pushed to the `main` branch
- Can also be manually triggered from the Actions tab
- Upload the entire repository content to GitHub Pages
- Deploy the site to your GitHub Pages URL

## How to Complete the Setup

To enable GitHub Pages for this repository, follow these steps:

1. **Merge this Pull Request** to the `main` branch

2. **Enable GitHub Pages in Repository Settings:**
   - Go to your repository on GitHub: `https://github.com/azhariemuhammad/whitenoisyy`
   - Click on **Settings** (top right menu)
   - Scroll down to **Pages** in the left sidebar
   - Under **Source**, select **GitHub Actions** (instead of "Deploy from a branch")
   - Click **Save**

3. **Trigger the Deployment:**
   - After merging to `main`, the workflow will automatically run
   - You can also manually trigger it from the **Actions** tab
   - Go to **Actions** → **Deploy to GitHub Pages** → **Run workflow**

4. **Access Your Website:**
   - Once deployed, your site will be available at:
   - `https://azhariemuhammad.github.io/whitenoisyy/`
   - The URL will also appear in the workflow run details

## Workflow Details

The workflow:
- Triggers on push to `main` branch
- Can be manually triggered via `workflow_dispatch`
- Uses official GitHub Actions for Pages deployment
- Requires `contents: read`, `pages: write`, and `id-token: write` permissions

## Troubleshooting

If the deployment doesn't work:
1. Check that GitHub Pages is enabled in repository settings with "GitHub Actions" as the source
2. Verify the workflow ran successfully in the Actions tab
3. Check the workflow logs for any errors
4. Ensure the repository has GitHub Pages enabled (it's available for public repos by default)

## About the Website

The `index.html` file contains a "Lite Rain" white noise web application featuring:
- Visual rain animation with CSS
- Web Audio API for synthesized rain sounds
- Responsive design optimized for mobile and desktop
- No external dependencies or heavy downloads
