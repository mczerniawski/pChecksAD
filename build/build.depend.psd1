@{
  Psake = 'latest'
  Pester = @{
   Name = 'Pester'
   DependencyType = 'PSGalleryModule'
   Parameters = @{
     Repository = 'PSGallery'
     SkipPublisherCheck = $true
   }
  }
  BuildHelpers = 'latest'
  PSScriptAnalyzer = 'latest'
}
